//
//  KitoBarsLoader.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Equalizer-style bars bouncing at staggered heights — reads as "actively
/// working," a good fit for audio/upload/processing contexts.
public struct KitoBarsLoader: View {
    @Environment(\.kitoTheme) private var theme
    @State private var isAnimating = false

    let barCount: Int
    let barWidth: CGFloat
    let maxHeight: CGFloat
    let color: Color?

    public init(barCount: Int = 5, barWidth: CGFloat = 5, maxHeight: CGFloat = 28, color: Color? = nil) {
        self.barCount = barCount
        self.barWidth = barWidth
        self.maxHeight = maxHeight
        self.color = color
    }

    public var body: some View {
        HStack(alignment: .center, spacing: barWidth * 0.6) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(color ?? theme.colors.primary)
                    .frame(width: barWidth, height: isAnimating ? maxHeight : maxHeight * 0.25)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever(autoreverses: true).delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
        }
        .frame(height: maxHeight)
        .onAppear { isAnimating = true }
        .accessibilityLabel("Loading")
    }
}
