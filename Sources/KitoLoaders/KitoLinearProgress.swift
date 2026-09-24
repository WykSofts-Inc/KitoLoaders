//
//  KitoLinearProgress.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A progress bar. With a `fraction` it fills (with a sheen travelling along the fill
/// and an optional percentage); with `nil` it's indeterminate — two segments chasing
/// across the track, the Material way. With Reduce Motion on, indeterminate bars
/// breathe in place instead.
public struct KitoLinearProgress: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let fraction: Double?
    let height: CGFloat
    let color: Color?
    let trackColor: Color?
    let label: String?
    let showsPercentage: Bool

    public init(fraction: Double? = nil, height: CGFloat = 6, color: Color? = nil, trackColor: Color? = nil,
                label: String? = nil, showsPercentage: Bool = false) {
        self.fraction = fraction.map { min(max($0, 0), 1) }
        self.height = height
        self.color = color
        self.trackColor = trackColor
        self.label = label
        self.showsPercentage = showsPercentage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if label != nil || (showsPercentage && fraction != nil) {
                HStack {
                    if let label {
                        Text(label).font(theme.typography.label).foregroundStyle(theme.colors.onBackground)
                    }
                    Spacer(minLength: 8)
                    if showsPercentage, let fraction {
                        Text(fraction, format: .percent.precision(.fractionLength(0)).rounded(rule: .toNearestOrAwayFromZero))
                            .font(theme.typography.label.monospacedDigit())
                            .foregroundStyle(theme.colors.onBackground.opacity(0.7))
                            .contentTransition(.numericText(value: fraction))
                    }
                }
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(trackColor ?? theme.colors.surfaceMuted)
                    if let fraction {
                        determinate(fraction: fraction, width: geometry.size.width)
                    } else {
                        indeterminate(width: geometry.size.width)
                    }
                }
            }
            .frame(height: height)
            .clipShape(Capsule())
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: fraction)
        .accessibilityElement()
        .accessibilityLabel(label ?? "Progress")
        .accessibilityValue(fraction.map { "\(Int($0 * 100)) percent" } ?? "In progress")
    }

    private var fill: Color { color ?? theme.colors.primary }

    private func determinate(fraction: Double, width: CGFloat) -> some View {
        Capsule()
            .fill(LinearGradient(colors: [fill.opacity(0.75), fill], startPoint: .leading, endPoint: .trailing))
            .frame(width: max(width * fraction, fraction > 0 ? height : 0))
            .kitoShimmer(isActive: fraction > 0 && fraction < 1, duration: 1.8, highlight: .white.opacity(0.45))
            .shadow(color: fill.opacity(0.4), radius: height, x: 0, y: 0)
    }

    private func indeterminate(width: CGFloat) -> some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            if reduceMotion {
                Capsule().fill(fill.opacity(0.35 + 0.35 * (1 + sin(time * 3)) / 2))
            } else {
                let phase = time.truncatingRemainder(dividingBy: 1.8) / 1.8
                ZStack(alignment: .leading) {
                    ForEach(0..<2, id: \.self) { index in
                        let segment = KitoLinearProgress.segment(phase: phase, index: index)
                        Capsule()
                            .fill(fill)
                            .frame(width: max(CGFloat(segment.end - segment.start) * width, 0))
                            .offset(x: CGFloat(segment.start) * width)
                    }
                }
            }
        }
    }

    /// Where indeterminate segment `index` (0 = long, 1 = short) spans, as 0...1 of the
    /// track, at `phase` 0...1 of the cycle.
    static func segment(phase: Double, index: Int) -> (start: Double, end: Double) {
        func ease(_ t: Double) -> Double { t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2 }
        func span(_ t: Double, head: Double, tail: Double) -> Double { ease(min(max((t - head) / (tail - head), 0), 1)) }
        let local = index == 0 ? phase : (phase - 0.45)
        guard local >= 0 else { return (0, 0) }
        let end = span(local, head: 0, tail: index == 0 ? 0.55 : 0.5) * 1.2 - 0.1
        let start = span(local, head: index == 0 ? 0.15 : 0.1, tail: 0.55) * 1.2 - 0.1
        return (min(max(start, 0), 1), min(max(end, 0), 1))
    }
}
