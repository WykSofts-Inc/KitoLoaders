//
//  KitoTypingIndicator.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// "Someone is typing…" — three dots hopping in turn inside a chat bubble with a
/// little tail. Drop the bubble with `showsBubble: false` to use the dots inline.
/// With Reduce Motion on, the dots fade in turn instead of hopping.
public struct KitoTypingIndicator: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let dotSize: CGFloat
    let dotColor: Color?
    let bubbleColor: Color?
    let showsBubble: Bool

    public init(dotSize: CGFloat = 8, dotColor: Color? = nil, bubbleColor: Color? = nil, showsBubble: Bool = true) {
        self.dotSize = dotSize
        self.dotColor = dotColor
        self.bubbleColor = bubbleColor
        self.showsBubble = showsBubble
    }

    public var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: dotSize * 0.55) {
                ForEach(0..<3, id: \.self) { index in
                    let lift = KitoTypingIndicator.lift(at: time, index: index)
                    Circle()
                        .fill(dotColor ?? theme.colors.onSurface.opacity(0.55))
                        .frame(width: dotSize, height: dotSize)
                        .opacity(0.35 + 0.65 * lift)
                        .offset(y: reduceMotion ? 0 : -lift * dotSize * 0.7)
                        .scaleEffect(reduceMotion ? 1 : 0.9 + 0.15 * lift)
                }
            }
            .padding(.horizontal, showsBubble ? dotSize * 1.9 : 0)
            .padding(.vertical, showsBubble ? dotSize * 1.5 : 0)
            .background {
                if showsBubble { bubble }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Typing")
    }

    private var bubble: some View {
        let color = bubbleColor ?? theme.colors.surfaceMuted
        return ZStack(alignment: .bottomLeading) {
            Capsule().fill(color)
            Circle().fill(color).frame(width: dotSize * 1.5, height: dotSize * 1.5).offset(x: -dotSize * 0.2, y: dotSize * 0.3)
            Circle().fill(color).frame(width: dotSize * 0.75, height: dotSize * 0.75).offset(x: -dotSize * 0.9, y: dotSize * 1.1)
        }
    }

    /// 0...1: how high dot `index` is at `time`. Each dot hops for a third of the
    /// 1.2 s cycle, one after another, then all rest.
    static func lift(at time: TimeInterval, index: Int) -> Double {
        let cycle = 1.2
        let phase = time.truncatingRemainder(dividingBy: cycle) / cycle
        let start = Double(index) * 0.18
        let local = (phase - start) / 0.36
        guard local > 0, local < 1 else { return 0 }
        return sin(local * .pi)
    }
}
