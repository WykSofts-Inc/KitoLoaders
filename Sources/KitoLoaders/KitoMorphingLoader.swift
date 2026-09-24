//
//  KitoMorphingLoader.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// One shape `KitoMorphingLoader` can flow through.
public enum KitoMorphForm: CaseIterable, Sendable {
    case circle, triangle, square, pentagon, hexagon, star

    /// Corner points on the unit circle, first corner pointing up (empty for `.circle`).
    var vertices: [CGPoint] {
        func polygon(_ sides: Int, flatTop: Bool) -> [CGPoint] {
            let start = -Double.pi / 2 + (flatTop ? .pi / Double(sides) : 0)
            return (0..<sides).map { index in
                let angle = start + 2 * .pi * Double(index) / Double(sides)
                return CGPoint(x: cos(angle), y: sin(angle))
            }
        }
        switch self {
        case .circle: return []
        case .triangle: return polygon(3, flatTop: false)
        case .square: return polygon(4, flatTop: true)
        case .pentagon: return polygon(5, flatTop: false)
        case .hexagon: return polygon(6, flatTop: true)
        case .star:
            return (0..<10).map { index in
                let angle = -Double.pi / 2 + .pi * Double(index) / 5
                let radius = index.isMultiple(of: 2) ? 1.0 : 0.5
                return CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            }
        }
    }

    /// How far the outline is from the centre in direction `angle`, as a fraction of the radius.
    func radius(at angle: Double) -> Double {
        let corners = vertices
        guard corners.count >= 3 else { return 1 }
        let direction = CGPoint(x: cos(angle), y: sin(angle))
        var nearest = Double.greatestFiniteMagnitude
        for index in corners.indices {
            let a = corners[index], b = corners[(index + 1) % corners.count]
            let edge = CGPoint(x: b.x - a.x, y: b.y - a.y)
            let denominator = Double(direction.x * edge.y - direction.y * edge.x)
            guard abs(denominator) > 1e-9 else { continue }
            let distance = Double(a.x * edge.y - a.y * edge.x) / denominator
            let along = Double(a.x * direction.y - a.y * direction.x) / denominator
            if distance > 0, along >= -1e-9, along <= 1 + 1e-9 { nearest = min(nearest, distance) }
        }
        return nearest == .greatestFiniteMagnitude ? 1 : nearest
    }
}

/// An outline that sits between two forms: `progress` 0 is `from`, 1 is `to`.
struct KitoMorphShape: Shape {
    var from: KitoMorphForm
    var to: KitoMorphForm
    var progress: Double
    /// Rounds corners by blending a little of a circle in.
    var softness: Double = 0.1

    func path(in rect: CGRect) -> Path {
        let samples = 144
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height) / 2
        var path = Path()
        for index in 0...samples {
            let angle = 2 * Double.pi * Double(index) / Double(samples) - .pi / 2
            let radius = KitoMorphShape.radius(from: from, to: to, progress: progress, softness: softness, angle: angle)
            let point = CGPoint(x: center.x + CGFloat(cos(angle) * radius) * size, y: center.y + CGFloat(sin(angle) * radius) * size)
            index == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }

    static func radius(from: KitoMorphForm, to: KitoMorphForm, progress: Double, softness: Double, angle: Double) -> Double {
        let t = min(max(progress, 0), 1)
        let blended = from.radius(at: angle) * (1 - t) + to.radius(at: angle) * t
        return blended * (1 - softness) + softness
    }
}

/// A blob that flows from shape to shape — circle, triangle, square, star… — while its
/// gradient turns. Playful for creative apps, onboarding and empty-ish waits. With
/// Reduce Motion on, it morphs in place without spinning.
public struct KitoMorphingLoader: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let size: CGFloat
    let forms: [KitoMorphForm]
    let colors: [Color]?
    let stepDuration: TimeInterval

    public init(size: CGFloat = 44, forms: [KitoMorphForm] = [.circle, .triangle, .square, .star, .hexagon],
                colors: [Color]? = nil, stepDuration: TimeInterval = 0.9) {
        self.size = size
        self.forms = forms.count >= 2 ? forms : [.circle, .square]
        self.colors = colors
        self.stepDuration = max(stepDuration, 0.2)
    }

    public var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let step = KitoMorphingLoader.step(at: time, stepDuration: stepDuration, count: forms.count)
            let palette = colors ?? [theme.colors.primary, theme.colors.secondary.opacity(0.9), theme.colors.primary]
            KitoMorphShape(from: forms[step.index], to: forms[(step.index + 1) % forms.count], progress: step.progress)
                .fill(AngularGradient(colors: palette + [palette[0]], center: .center, angle: .degrees(time * 90)))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(reduceMotion ? 0 : time * 60))
                .shadow(color: palette[0].opacity(0.35), radius: size * 0.2, y: size * 0.08)
        }
        .frame(width: size * 1.2, height: size * 1.2)
        .accessibilityElement()
        .accessibilityLabel("Loading")
    }

    /// Which form is on screen at `time`, and how far (eased 0...1) into the morph to the next.
    /// Each step holds its shape for the first 35 % before flowing on.
    static func step(at time: TimeInterval, stepDuration: TimeInterval, count: Int) -> (index: Int, progress: Double) {
        guard count > 0 else { return (0, 0) }
        let total = time / stepDuration
        let index = Int(floor(total)) % count
        let local = total - floor(total)
        let moving = max(0, (local - 0.35) / 0.65)
        let eased = moving < 0.5 ? 4 * pow(moving, 3) : 1 - pow(-2 * moving + 2, 3) / 2
        return ((index + count) % count, eased)
    }
}
