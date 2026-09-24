//
//  KitoSkeletonView.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A ready-made placeholder layout for `KitoSkeletonView`.
public enum KitoSkeletonTemplate: CaseIterable, Sendable {
    /// Avatar, two lines and a trailing pill — contacts, transactions, settings.
    case listRow
    /// A cover image, a title, two lines and a footer.
    case card
    /// A big avatar, name, handle, three stats and a button.
    case profile
    /// A social post: header, text, a photo and an action row.
    case feedPost
    /// Chat bubbles, alternating sides.
    case chat
    /// A two-column grid of tiles with captions — a product catalogue.
    case grid
    /// A headline, byline, hero image and paragraphs.
    case article
}

/// Placeholder content in the shape of what's coming — a list, a card, a profile, a
/// feed — shimmering in one coherent sweep. Line widths vary by row so a list of
/// skeletons doesn't look machine-stamped.
public struct KitoSkeletonView: View {
    @Environment(\.kitoTheme) private var theme

    let template: KitoSkeletonTemplate
    let count: Int
    let spacing: CGFloat
    let isAnimating: Bool

    public init(_ template: KitoSkeletonTemplate, count: Int = 1, spacing: CGFloat = 20, isAnimating: Bool = true) {
        self.template = template
        self.count = max(count, 1)
        self.spacing = spacing
        self.isAnimating = isAnimating
    }

    public var body: some View {
        Group {
            if template == .grid {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: spacing) {
                    ForEach(0..<count * 2, id: \.self) { gridTile(row: $0) }
                }
            } else {
                VStack(alignment: .leading, spacing: spacing) {
                    ForEach(0..<count, id: \.self) { row in item(row: row) }
                }
            }
        }
        .kitoShimmer(isActive: isAnimating)
        .accessibilityElement()
        .accessibilityLabel("Loading")
    }

    @ViewBuilder
    private func item(row: Int) -> some View {
        switch template {
        case .listRow: listRow(row: row)
        case .card: card(row: row)
        case .profile: profile
        case .feedPost: feedPost(row: row)
        case .chat: chat(row: row)
        case .grid: gridTile(row: row)
        case .article: article(row: row)
        }
    }

    // MARK: Templates

    private func listRow(row: Int) -> some View {
        HStack(spacing: 14) {
            Circle().fill(fill).frame(width: 46, height: 46)
            VStack(alignment: .leading, spacing: 8) {
                line(fraction: KitoSkeletonTemplate.lineFraction(row: row, line: 0), height: 12)
                line(fraction: KitoSkeletonTemplate.lineFraction(row: row, line: 1) * 0.6, height: 10)
            }
            Capsule().fill(fill).frame(width: 54, height: 22)
        }
    }

    private func card(row: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(fill).aspectRatio(16 / 9, contentMode: .fit)
            line(fraction: 0.7, height: 16)
            line(fraction: KitoSkeletonTemplate.lineFraction(row: row, line: 1), height: 10)
            line(fraction: KitoSkeletonTemplate.lineFraction(row: row, line: 2) * 0.8, height: 10)
            HStack(spacing: 10) {
                Circle().fill(fill).frame(width: 26, height: 26)
                line(fraction: 0.35, height: 10)
                Spacer(minLength: 0)
                Capsule().fill(fill).frame(width: 70, height: 28)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(fill, lineWidth: 1.5))
    }

    private var profile: some View {
        VStack(spacing: 14) {
            Circle().fill(fill).frame(width: 88, height: 88)
            RoundedRectangle(cornerRadius: 6).fill(fill).frame(width: 150, height: 16)
            RoundedRectangle(cornerRadius: 5).fill(fill).frame(width: 96, height: 11)
            HStack(spacing: 28) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 5).fill(fill).frame(width: 40, height: 16)
                        RoundedRectangle(cornerRadius: 4).fill(fill).frame(width: 54, height: 9)
                    }
                }
            }
            .padding(.top, 6)
            Capsule().fill(fill).frame(height: 44).padding(.horizontal, 30).padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
    }

    private func feedPost(row: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle().fill(fill).frame(width: 38, height: 38)
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 5).fill(fill).frame(width: 120, height: 11)
                    RoundedRectangle(cornerRadius: 4).fill(fill).frame(width: 70, height: 9)
                }
                Spacer(minLength: 0)
                Capsule().fill(fill).frame(width: 22, height: 8)
            }
            line(fraction: KitoSkeletonTemplate.lineFraction(row: row, line: 0), height: 10)
            line(fraction: KitoSkeletonTemplate.lineFraction(row: row, line: 1) * 0.75, height: 10)
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(fill).aspectRatio(4 / 3, contentMode: .fit)
            HStack(spacing: 18) {
                ForEach(0..<3, id: \.self) { _ in Circle().fill(fill).frame(width: 24, height: 24) }
                Spacer(minLength: 0)
                RoundedRectangle(cornerRadius: 4).fill(fill).frame(width: 60, height: 10)
            }
        }
    }

    private func chat(row: Int) -> some View {
        let fromMe = row % 2 == 1
        let width = 0.45 + KitoSkeletonTemplate.lineFraction(row: row, line: 3) * 0.35
        return HStack(alignment: .bottom, spacing: 8) {
            if !fromMe { Circle().fill(fill).frame(width: 28, height: 28) }
            GeometryReader { geometry in
                UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: fromMe ? 18 : 4,
                                       bottomTrailingRadius: fromMe ? 4 : 18, topTrailingRadius: 18, style: .continuous)
                    .fill(fill)
                    .frame(width: geometry.size.width * width)
                    .frame(maxWidth: .infinity, alignment: fromMe ? .trailing : .leading)
            }
            .frame(height: row % 3 == 0 ? 56 : 38)
        }
    }

    private func gridTile(row: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(fill).aspectRatio(1, contentMode: .fit)
            line(fraction: KitoSkeletonTemplate.lineFraction(row: row, line: 0), height: 11)
            RoundedRectangle(cornerRadius: 4).fill(fill).frame(width: 48, height: 10)
        }
    }

    private func article(row: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            line(fraction: 0.95, height: 20)
            line(fraction: 0.6, height: 20)
            HStack(spacing: 8) {
                Circle().fill(fill).frame(width: 22, height: 22)
                RoundedRectangle(cornerRadius: 4).fill(fill).frame(width: 110, height: 9)
            }
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(fill).frame(height: 170)
            ForEach(0..<4, id: \.self) { index in
                line(fraction: index == 3 ? 0.55 : KitoSkeletonTemplate.lineFraction(row: row, line: index), height: 10)
            }
        }
    }

    // MARK: Pieces

    private var fill: Color { theme.colors.surfaceMuted }

    private func line(fraction: Double, height: CGFloat) -> some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: height / 2)
                .fill(fill)
                .frame(width: geometry.size.width * fraction)
        }
        .frame(height: height)
    }
}

extension KitoSkeletonTemplate {
    /// A stable 0.55...1 width for line `line` of row `row`, so rows look hand-set.
    static func lineFraction(row: Int, line: Int) -> Double {
        let seed = (row &* 7919 &+ line &* 104_729) & 0xFFFF
        let unit = Double(seed % 1000) / 1000
        return 0.55 + unit * 0.45
    }
}
