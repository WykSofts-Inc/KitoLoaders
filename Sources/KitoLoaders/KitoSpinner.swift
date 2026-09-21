//
//  KitoSpinner.swift
//  KitoLoaders
//
//  Created by Wycliff on 2/16/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A rotating-arc spinner. Color defaults to the current `kitoTheme`'s primary.
public struct KitoSpinner: View {
    @Environment(\.kitoTheme) private var theme
    @State private var isRotating = false

    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color?

    public init(size: CGFloat = 24, lineWidth: CGFloat = 3, color: Color? = nil) {
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
    }

    public var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(color ?? theme.colors.primary, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isRotating)
            .onAppear { isRotating = true }
            .accessibilityLabel("Loading")
    }
}
