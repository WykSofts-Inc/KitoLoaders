//
//  KitoLoaderView.swift
//  KitoLoaders
//
//  Created by Wycliff on 2/12/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Renders whichever loader `KitoLoaderStyle.kind` names. Use this when the
/// loader kind is configuration (a screen's `loaderStyle` parameter) rather
/// than a compile-time choice — e.g. `KitoScreens` uses this internally so a
/// consumer can swap every screen's loader by changing one enum value.
public struct KitoLoaderView: View {
    let style: KitoLoaderStyle
    let color: Color?

    public init(style: KitoLoaderStyle = .default, color: Color? = nil) {
        self.style = style
        self.color = color
    }

    public var body: some View {
        switch style.kind {
        case .spinner:
            KitoSpinner(size: style.size, lineWidth: style.lineWidth, color: color)
        case .dots:
            KitoDotsLoader(dotSize: style.size / 3, color: color)
        case .pulse:
            KitoPulseLoader(size: style.size, color: color)
        case .progressRing(let fraction):
            KitoProgressRing(fraction: fraction, size: style.size, lineWidth: style.lineWidth, color: color)
        case .skeleton:
            KitoSkeleton()
                .frame(width: style.size * 3, height: style.size)
        case .bars:
            KitoBarsLoader(barWidth: style.size / 6, maxHeight: style.size, color: color)
        case .wave:
            KitoWaveLoader(dotSize: style.size / 3, color: color)
        case .ripple:
            KitoRippleLoader(size: style.size, color: color)
        case .orbit:
            KitoOrbitLoader(size: style.size, color: color)
        case .gradientRing:
            KitoGradientRingLoader(size: style.size, lineWidth: style.lineWidth, colors: color.map { [$0.opacity(0), $0] })
        }
    }
}
