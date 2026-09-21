//
//  KitoOrbitLoader.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Small dots orbiting a center point, each dimmer than the last so the
/// direction of travel reads at a glance. `TimelineView`-driven, same as
/// `KitoWaveLoader`, for exact continuous motion.
public struct KitoOrbitLoader: View {
    @Environment(\.kitoTheme) private var theme

    let size: CGFloat
    let dotCount: Int
    let color: Color?

    public init(size: CGFloat = 32, dotCount: Int = 3, color: Color? = nil) {
        self.size = size
        self.dotCount = dotCount
        self.color = color
    }

    public var body: some View {
        TimelineView(.animation) { context in
            let angle = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: 1.5) / 1.5 * 2 * .pi
            ZStack {
                ForEach(0..<dotCount, id: \.self) { index in
                    let offsetAngle = angle + (2 * .pi / Double(dotCount)) * Double(index)
                    Circle()
                        .fill((color ?? theme.colors.primary).opacity(1 - Double(index) * (0.6 / Double(dotCount))))
                        .frame(width: size * 0.18, height: size * 0.18)
                        .offset(x: cos(offsetAngle) * size / 2, y: sin(offsetAngle) * size / 2)
                }
            }
            .frame(width: size, height: size)
        }
        .accessibilityLabel("Loading")
    }
}
