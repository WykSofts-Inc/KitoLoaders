//
//  KitoRippleLoader.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Concentric rings expanding and fading outward, staggered in phase — a
/// "radar ping" reads as ongoing background activity better than a single
/// pulse (`KitoPulseLoader`) when there's more visual weight to fill.
public struct KitoRippleLoader: View {
    @Environment(\.kitoTheme) private var theme
    @State private var isAnimating = false

    let size: CGFloat
    let ringCount: Int
    let color: Color?

    public init(size: CGFloat = 40, ringCount: Int = 3, color: Color? = nil) {
        self.size = size
        self.ringCount = ringCount
        self.color = color
    }

    public var body: some View {
        ZStack {
            ForEach(0..<ringCount, id: \.self) { index in
                Circle()
                    .stroke(color ?? theme.colors.primary, lineWidth: 2)
                    .scaleEffect(isAnimating ? 1 : 0.2)
                    .opacity(isAnimating ? 0 : 0.8)
                    .animation(
                        .easeOut(duration: 1.4).repeatForever(autoreverses: false).delay(Double(index) * (1.4 / Double(ringCount))),
                        value: isAnimating
                    )
            }
        }
        .frame(width: size, height: size)
        .onAppear { isAnimating = true }
        .accessibilityLabel("Loading")
    }
}
