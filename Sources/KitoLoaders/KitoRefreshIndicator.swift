//
//  KitoRefreshIndicator.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A pull-to-refresh indicator: a ring that draws itself as you pull, with an arrow
/// that flips once you've pulled far enough, then a spinning gradient ring while
/// refreshing. `KitoRefreshableScrollView` wires it up; use it alone to drive your own.
public struct KitoRefreshIndicator: View {
    @Environment(\.kitoTheme) private var theme

    let pullProgress: Double
    let isRefreshing: Bool
    let size: CGFloat
    let color: Color?

    public init(pullProgress: Double, isRefreshing: Bool, size: CGFloat = 30, color: Color? = nil) {
        self.pullProgress = min(max(pullProgress, 0), 1)
        self.isRefreshing = isRefreshing
        self.size = size
        self.color = color
    }

    public var body: some View {
        ZStack {
            if isRefreshing {
                KitoGradientRingLoader(size: size, lineWidth: 3, colors: color.map { [$0.opacity(0), $0] })
                    .transition(.scale.combined(with: .opacity))
            } else {
                Circle()
                    .trim(from: 0, to: pullProgress * 0.92)
                    .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90 + pullProgress * 120))
                    .frame(width: size, height: size)
                Image(systemName: "arrow.down")
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(tint)
                    .rotationEffect(.degrees(pullProgress >= 1 ? 180 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pullProgress >= 1)
                    .opacity(0.3 + 0.7 * pullProgress)
            }
        }
        .frame(width: size + 14, height: size + 14)
        .background(.regularMaterial, in: Circle())
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        .scaleEffect(isRefreshing ? 1 : 0.6 + 0.4 * pullProgress)
        .opacity(isRefreshing ? 1 : min(pullProgress * 2, 1))
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isRefreshing)
        .accessibilityElement()
        .accessibilityLabel(isRefreshing ? "Refreshing" : "Pull to refresh")
    }

    private var tint: Color { color ?? theme.colors.primary }
}

/// A `ScrollView` with `KitoRefreshIndicator` as its pull-to-refresh: pull past
/// `threshold` and `onRefresh` runs, holding the indicator open until it returns.
public struct KitoRefreshableScrollView<Content: View>: View {
    let threshold: CGFloat
    let color: Color?
    let onRefresh: () async -> Void
    let content: Content

    @State private var pull: CGFloat = 0
    @State private var isRefreshing = false
    @State private var isArmed = true
    private let space = "KitoRefreshableScrollView"

    public init(threshold: CGFloat = 80, color: Color? = nil, onRefresh: @escaping () async -> Void, @ViewBuilder content: () -> Content) {
        self.threshold = threshold
        self.color = color
        self.onRefresh = onRefresh
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    Color.clear.preference(key: KitoRefreshOffsetKey.self, value: geometry.frame(in: .named(space)).minY)
                }
                .frame(height: 0)
                Color.clear.frame(height: isRefreshing ? 64 : 0)
                content
            }
        }
        .coordinateSpace(name: space)
        .overlay(alignment: .top) {
            KitoRefreshIndicator(pullProgress: KitoRefreshMath.progress(offset: pull, threshold: threshold), isRefreshing: isRefreshing, color: color)
                .offset(y: isRefreshing ? 12 : KitoRefreshMath.indicatorOffset(offset: pull))
                .allowsHitTesting(false)
        }
        .onPreferenceChange(KitoRefreshOffsetKey.self) { offset in
            pull = max(offset, 0)
            if pull < 4 { isArmed = true }
            guard isArmed, !isRefreshing, pull >= threshold else { return }
            isArmed = false
            Task { await refresh() }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isRefreshing)
    }

    @MainActor
    private func refresh() async {
        isRefreshing = true
        await onRefresh()
        isRefreshing = false
    }
}

struct KitoRefreshOffsetKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

enum KitoRefreshMath {
    /// 0...1: how far the pull is towards triggering.
    static func progress(offset: CGFloat, threshold: CGFloat) -> Double {
        guard threshold > 0 else { return 1 }
        return Double(min(max(offset / threshold, 0), 1))
    }

    /// The indicator follows the pull at half speed, starting tucked above the top edge.
    static func indicatorOffset(offset: CGFloat) -> CGFloat {
        -44 + max(offset, 0) * 0.6
    }
}
