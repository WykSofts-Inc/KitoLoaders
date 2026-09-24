//
//  KitoHeartbeatLoader.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A glowing ECG trace running across a faint monitor line, optionally with a heart
/// that beats in time — health, fitness and "connecting to your device" screens.
/// With Reduce Motion on, the trace stays still and the heart fades on each beat.
public struct KitoHeartbeatLoader: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let width: CGFloat
    let height: CGFloat
    let lineWidth: CGFloat
    let color: Color?
    let beatsPerMinute: Double
    let showsHeart: Bool

    public init(width: CGFloat = 140, height: CGFloat = 44, lineWidth: CGFloat = 2.5, color: Color? = nil,
                beatsPerMinute: Double = 72, showsHeart: Bool = false) {
        self.width = width
        self.height = height
        self.lineWidth = lineWidth
        self.color = color
        self.beatsPerMinute = min(max(beatsPerMinute, 30), 200)
        self.showsHeart = showsHeart
    }

    private var beat: TimeInterval { 60 / beatsPerMinute }

    public var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let phase = time.truncatingRemainder(dividingBy: beat * 2) / (beat * 2)
            HStack(spacing: 12) {
                if showsHeart {
                    let pulse = KitoHeartbeatLoader.pulse(at: time.truncatingRemainder(dividingBy: beat) / beat)
                    Image(systemName: "heart.fill")
                        .font(.system(size: height * 0.55))
                        .foregroundStyle(tint.gradient)
                        .scaleEffect(reduceMotion ? 1 : 1 + 0.22 * pulse)
                        .opacity(reduceMotion ? 0.55 + 0.45 * pulse : 1)
                        .shadow(color: tint.opacity(0.5 * pulse), radius: 8)
                }
                Canvas { canvas, size in
                    draw(in: &canvas, size: size, head: reduceMotion ? 1 : phase)
                }
                .frame(width: width, height: height)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Loading")
    }

    private var tint: Color { color ?? theme.colors.danger }

    private func draw(in canvas: inout GraphicsContext, size: CGSize, head: Double) {
        let samples = 160
        func point(_ unit: Double) -> CGPoint {
            // Two beats across the width.
            let local = (unit * 2).truncatingRemainder(dividingBy: 1)
            let y = KitoHeartbeatLoader.ecg(local)
            return CGPoint(x: CGFloat(unit) * size.width, y: size.height / 2 - CGFloat(y) * size.height * 0.45)
        }

        var full = Path()
        for index in 0...samples {
            let unit = Double(index) / Double(samples)
            index == 0 ? full.move(to: point(unit)) : full.addLine(to: point(unit))
        }
        canvas.stroke(full, with: .color(tint.opacity(0.14)), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))

        // The bright trail: short segments fading out behind the head.
        let trail = 0.45
        let steps = 48
        for step in 0..<steps {
            let from = head - trail * Double(steps - step) / Double(steps)
            let to = head - trail * Double(steps - step - 1) / Double(steps)
            guard to > 0 else { continue }
            var segment = Path()
            segment.move(to: point(max(from, 0)))
            segment.addLine(to: point(to))
            let alpha = Double(step + 1) / Double(steps)
            canvas.stroke(segment, with: .color(tint.opacity(alpha)), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }

        let tip = point(head)
        var glow = canvas
        glow.addFilter(.blur(radius: 5))
        glow.fill(Path(ellipseIn: CGRect(x: tip.x - 6, y: tip.y - 6, width: 12, height: 12)), with: .color(tint.opacity(0.8)))
        canvas.fill(Path(ellipseIn: CGRect(x: tip.x - lineWidth * 1.3, y: tip.y - lineWidth * 1.3, width: lineWidth * 2.6, height: lineWidth * 2.6)),
                    with: .color(.white))
    }

    /// The ECG shape over one beat, `unit` 0...1 → -1...1: flat, a small P wave, the
    /// sharp QRS spike, then a rounded T wave.
    static func ecg(_ unit: Double) -> Double {
        func bump(_ center: Double, _ width: Double, _ height: Double) -> Double {
            let distance = (unit - center) / width
            return height * exp(-distance * distance)
        }
        return bump(0.18, 0.035, 0.18)   // P
            + bump(0.34, 0.012, -0.25)   // Q
            + bump(0.38, 0.016, 1.0)     // R
            + bump(0.42, 0.014, -0.45)   // S
            + bump(0.62, 0.06, 0.3)      // T
    }

    /// The heart's "lub-dub" swell over one beat, 0...1.
    static func pulse(at unit: Double) -> Double {
        let lub = exp(-pow((unit - 0.1) / 0.06, 2))
        let dub = 0.6 * exp(-pow((unit - 0.3) / 0.06, 2))
        return min(lub + dub, 1)
    }
}
