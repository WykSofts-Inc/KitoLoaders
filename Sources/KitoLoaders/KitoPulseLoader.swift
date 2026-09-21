//
//  KitoPulseLoader.swift
//  KitoLoaders
//
//  Created by Wycliff on 2/14/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A circle that pulses outward and fades — good for a single, low-attention
/// "something is happening" indicator (e.g. a background sync icon).
public struct KitoPulseLoader: View {
    @Environment(\.kitoTheme) private var theme
    @State private var isPulsing = false

    let size: CGFloat
    let color: Color?

    public init(size: CGFloat = 24, color: Color? = nil) {
        self.size = size
        self.color = color
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(color ?? theme.colors.primary)
                .frame(width: size, height: size)
                .scaleEffect(isPulsing ? 1.8 : 1.0)
                .opacity(isPulsing ? 0 : 0.5)
                .animation(.easeOut(duration: 1.1).repeatForever(autoreverses: false), value: isPulsing)

            Circle()
                .fill(color ?? theme.colors.primary)
                .frame(width: size, height: size)
        }
        .onAppear { isPulsing = true }
        .accessibilityLabel("Loading")
    }
}
