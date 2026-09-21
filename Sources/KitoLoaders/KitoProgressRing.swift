//
//  KitoProgressRing.swift
//  KitoLoaders
//
//  Created by Wycliff on 2/13/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A determinate ring for a known fraction (upload progress, multi-step
/// onboarding). For unknown-duration work use `KitoSpinner` instead.
public struct KitoProgressRing: View {
    @Environment(\.kitoTheme) private var theme

    let fraction: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color?
    let showsPercentage: Bool

    public init(
        fraction: Double,
        size: CGFloat = 48,
        lineWidth: CGFloat = 5,
        color: Color? = nil,
        showsPercentage: Bool = true
    ) {
        self.fraction = min(max(fraction, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
        self.showsPercentage = showsPercentage
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(theme.colors.surfaceMuted, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(color ?? theme.colors.primary, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.3), value: fraction)
            if showsPercentage {
                Text("\(Int(fraction * 100))%")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.onBackground)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("\(Int(fraction * 100)) percent complete")
    }
}
