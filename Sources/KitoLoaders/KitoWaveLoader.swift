//
//  KitoWaveLoader.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A row of dots riding a continuous sine wave, each phase-shifted from its
/// neighbor. Driven by `TimelineView` (wall-clock time) rather than a
/// `@State` progress value — smooth and exact regardless of how long the
/// view has been on screen, with no manual animation bookkeeping.
public struct KitoWaveLoader: View {
    @Environment(\.kitoTheme) private var theme

    let dotCount: Int
    let dotSize: CGFloat
    let color: Color?

    public init(dotCount: Int = 5, dotSize: CGFloat = 8, color: Color? = nil) {
        self.dotCount = dotCount
        self.dotSize = dotSize
        self.color = color
    }

    public var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: dotSize * 0.7) {
                ForEach(0..<dotCount, id: \.self) { index in
                    Circle()
                        .fill(color ?? theme.colors.primary)
                        .frame(width: dotSize, height: dotSize)
                        .offset(y: CGFloat(sin(t * 4 - Double(index) * 0.6)) * dotSize)
                }
            }
        }
        .accessibilityLabel("Loading")
    }
}
