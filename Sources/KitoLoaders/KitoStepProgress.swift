//
//  KitoStepProgress.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Progress through named steps — checkout, onboarding, an order on its way.
/// `.dots` numbers each step and ticks it off; `.segments` is a row of capsules, like
/// story progress, with the current one partly filled by `stepFraction`.
public struct KitoStepProgress: View {
    public enum Style: Sendable {
        case dots
        case segments
    }

    @Environment(\.kitoTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let steps: [String]
    let current: Int
    let stepFraction: Double
    let style: Style
    let color: Color?

    /// - Parameters:
    ///   - current: the index of the step in progress; `steps.count` means all done.
    ///   - stepFraction: how far into the current step, for `.segments`.
    public init(steps: [String], current: Int, stepFraction: Double = 0.5, style: Style = .dots, color: Color? = nil) {
        self.steps = steps
        self.current = KitoStepProgress.clampedStep(current, count: steps.count)
        self.stepFraction = min(max(stepFraction, 0), 1)
        self.style = style
        self.color = color
    }

    public var body: some View {
        Group {
            switch style {
            case .dots: dots
            case .segments: segments
            }
        }
        .animation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.5, dampingFraction: 0.8), value: current)
        .animation(.easeInOut(duration: 0.3), value: stepFraction)
        .accessibilityElement()
        .accessibilityLabel("Step \(min(current + 1, steps.count)) of \(steps.count)")
        .accessibilityValue(current < steps.count ? steps[current] : "Complete")
    }

    private var tint: Color { color ?? theme.colors.primary }

    // MARK: Dots

    private var dots: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(steps.indices, id: \.self) { index in
                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        connector(filled: index <= current, visible: index > 0)
                        marker(index)
                        connector(filled: index < current, visible: index < steps.count - 1)
                    }
                    Text(steps[index])
                        .font(theme.typography.caption.weight(index == current ? .semibold : .regular))
                        .foregroundStyle(theme.colors.onBackground.opacity(index <= current ? 1 : 0.45))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func marker(_ index: Int) -> some View {
        let done = index < current
        let active = index == current
        return ZStack {
            Circle()
                .fill(done || active ? tint : theme.colors.surfaceMuted)
                .frame(width: 28, height: 28)
            if done {
                Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundStyle(theme.colors.onPrimary)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(active ? theme.colors.onPrimary : theme.colors.onBackground.opacity(0.5))
            }
        }
        .background {
            if active && !reduceMotion {
                KitoStepPulse(color: tint)
            }
        }
    }

    private func connector(filled: Bool, visible: Bool) -> some View {
        ZStack(alignment: .leading) {
            Capsule().fill(theme.colors.surfaceMuted)
            Capsule().fill(tint).scaleEffect(x: filled ? 1 : 0, anchor: .leading)
        }
        .frame(height: 3)
        .opacity(visible ? 1 : 0)
    }

    // MARK: Segments

    private var segments: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                ForEach(steps.indices, id: \.self) { index in
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule().fill(theme.colors.surfaceMuted)
                            Capsule().fill(tint)
                                .frame(width: geometry.size.width * KitoStepProgress.segmentFill(index: index, current: current, fraction: stepFraction))
                        }
                    }
                    .frame(height: 5)
                }
            }
            if current < steps.count {
                Text(steps[current])
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.onBackground.opacity(0.7))
                    .contentTransition(.opacity)
            }
        }
    }

    static func clampedStep(_ step: Int, count: Int) -> Int { min(max(step, 0), count) }

    /// How full segment `index` is: done ones full, the current one `fraction`, the rest empty.
    static func segmentFill(index: Int, current: Int, fraction: Double) -> Double {
        if index < current { return 1 }
        if index == current { return fraction }
        return 0
    }
}

/// A soft ring breathing out from the current step.
private struct KitoStepPulse: View {
    let color: Color
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .stroke(color.opacity(isAnimating ? 0 : 0.5), lineWidth: 3)
            .frame(width: 28, height: 28)
            .scaleEffect(isAnimating ? 1.6 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 1.3).repeatForever(autoreverses: false)) { isAnimating = true }
            }
    }
}
