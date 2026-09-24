//
//  KitoShimmer.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Sweeps a soft highlight across whatever it modifies, masked to its shape.
/// With Reduce Motion on, the highlight breathes in place instead of sweeping.
struct KitoShimmerModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isActive: Bool
    let duration: TimeInterval
    let highlight: Color?

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay {
                    TimelineView(.animation) { context in
                        let phase = KitoShimmerMath.phase(at: context.date.timeIntervalSinceReferenceDate, duration: duration)
                        GeometryReader { geometry in
                            if reduceMotion {
                                highlightColor.opacity(0.5 + 0.5 * sin(phase * 2 * .pi))
                            } else {
                                let band = max(geometry.size.width * 0.45, 80)
                                LinearGradient(colors: [.clear, highlightColor, .clear], startPoint: .leading, endPoint: .trailing)
                                    .frame(width: band, height: geometry.size.height * 3)
                                    .rotationEffect(.degrees(18))
                                    .offset(x: KitoShimmerMath.offset(phase: phase, width: geometry.size.width, band: band),
                                            y: -geometry.size.height)
                            }
                        }
                    }
                    .mask(content)
                    .allowsHitTesting(false)
                }
        } else {
            content
        }
    }

    private var highlightColor: Color {
        highlight ?? Color.white.opacity(colorScheme == .dark ? 0.14 : 0.65)
    }
}

enum KitoShimmerMath {
    /// 0...1 through each sweep, on the wall clock so every shimmer on screen moves together.
    static func phase(at time: TimeInterval, duration: TimeInterval) -> Double {
        let duration = max(duration, 0.1)
        let raw = time.truncatingRemainder(dividingBy: duration) / duration
        return raw < 0 ? raw + 1 : raw
    }

    /// Where the highlight band sits: fully off the left edge at 0, fully off the right at 1.
    static func offset(phase: Double, width: CGFloat, band: CGFloat) -> CGFloat {
        -band + CGFloat(phase) * (width + band * 2)
    }
}

public extension View {
    /// Sweeps a shimmering highlight across this view while `isActive` — put it on any
    /// placeholder shape, or on a whole skeleton so every block shimmers in one pass.
    func kitoShimmer(isActive: Bool = true, duration: TimeInterval = 1.4, highlight: Color? = nil) -> some View {
        modifier(KitoShimmerModifier(isActive: isActive, duration: duration, highlight: highlight))
    }

    /// Redacts this view into placeholder bars that shimmer while `isLoading`, and blocks
    /// taps on it. The real layout stays, so nothing jumps when the data lands.
    func kitoRedacted(isLoading: Bool, duration: TimeInterval = 1.4) -> some View {
        redacted(reason: isLoading ? .placeholder : [])
            .kitoShimmer(isActive: isLoading, duration: duration)
            .allowsHitTesting(!isLoading)
            .animation(.easeInOut(duration: 0.3), value: isLoading)
    }
}
