//
//  KitoGradientRingLoader.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// `KitoSpinner`'s fancier sibling — a spinning ring stroked with an angular
/// gradient (fading into the theme's primary color) instead of a flat
/// stroke, so the direction of rotation reads clearly even at rest frames.
public struct KitoGradientRingLoader: View {
    @Environment(\.kitoTheme) private var theme
    @State private var isRotating = false

    let size: CGFloat
    let lineWidth: CGFloat
    let colors: [Color]?

    public init(size: CGFloat = 28, lineWidth: CGFloat = 4, colors: [Color]? = nil) {
        self.size = size
        self.lineWidth = lineWidth
        self.colors = colors
    }

    public var body: some View {
        Circle()
            .stroke(
                AngularGradient(colors: colors ?? [(theme.colors.primary).opacity(0), theme.colors.primary], center: .center),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(.linear(duration: 0.9).repeatForever(autoreverses: false), value: isRotating)
            .onAppear { isRotating = true }
            .accessibilityLabel("Loading")
    }
}
