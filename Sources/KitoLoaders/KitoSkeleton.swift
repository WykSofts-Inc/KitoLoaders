//
//  KitoSkeleton.swift
//  KitoLoaders
//
//  Created by Wycliff on 2/15/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A shimmering placeholder block, and a modifier to swap any view for one
/// while `isLoading` is true — the standard "content skeleton" pattern for
/// lists/cards.
public struct KitoSkeleton: View {
    @Environment(\.kitoTheme) private var theme
    @State private var shimmerX: CGFloat = -1

    let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = 6) {
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(theme.colors.surfaceMuted)
                .overlay(
                    LinearGradient(
                        colors: [.clear, theme.colors.surface.opacity(0.6), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .offset(x: shimmerX * geometry.size.width * 1.6)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        shimmerX = 1
                    }
                }
        }
        .accessibilityHidden(true)
    }
}

public extension View {
    /// Replaces this view with a `KitoSkeleton` of the same shape while
    /// `isLoading` is true. The real content stays in the hierarchy (hidden,
    /// not removed) so layout doesn't jump when loading finishes.
    @ViewBuilder
    func kitoSkeleton(isLoading: Bool, cornerRadius: CGFloat = 6) -> some View {
        if isLoading {
            self.hidden().overlay(KitoSkeleton(cornerRadius: cornerRadius))
        } else {
            self
        }
    }
}
