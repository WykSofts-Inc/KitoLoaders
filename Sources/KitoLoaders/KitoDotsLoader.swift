//
//  KitoDotsLoader.swift
//  KitoLoaders
//
//  Created by Wycliff on 2/11/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Three dots bouncing in sequence — the "typing indicator" loader.
public struct KitoDotsLoader: View {
    @Environment(\.kitoTheme) private var theme
    @State private var phase = 0

    let dotSize: CGFloat
    let color: Color?

    public init(dotSize: CGFloat = 8, color: Color? = nil) {
        self.dotSize = dotSize
        self.color = color
    }

    public var body: some View {
        HStack(spacing: dotSize * 0.6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(color ?? theme.colors.primary)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(phase == index ? 1.0 : 0.6)
                    .opacity(phase == index ? 1.0 : 0.4)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).repeatForever()) {
                // Timer-driven index advance keeps the animation deterministic
                // across accessibility "reduce motion" without stalling.
            }
            Task { await animatePhases() }
        }
        .accessibilityLabel("Loading")
    }

    @MainActor
    private func animatePhases() async {
        while !Task.isCancelled {
            for index in 0..<3 {
                withAnimation(.easeInOut(duration: 0.3)) { phase = index }
                try? await Task.sleep(nanoseconds: 250_000_000)
            }
        }
    }
}
