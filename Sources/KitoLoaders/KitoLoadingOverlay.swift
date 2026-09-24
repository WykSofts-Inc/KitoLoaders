//
//  KitoLoadingOverlay.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A frosted card with a loader, a message and an optional detail or progress —
/// what `kitoLoadingOverlay` shows over the blurred screen. Usable on its own too.
public struct KitoLoadingCard: View {
    @Environment(\.kitoTheme) private var theme

    let message: String?
    let detail: String?
    let progress: Double?
    let loader: KitoLoaderStyle
    let color: Color?

    public init(message: String? = nil, detail: String? = nil, progress: Double? = nil,
                loader: KitoLoaderStyle = KitoLoaderStyle(kind: .gradientRing, size: 44, lineWidth: 4), color: Color? = nil) {
        self.message = message
        self.detail = detail
        self.progress = progress
        self.loader = loader
        self.color = color
    }

    public var body: some View {
        VStack(spacing: theme.spacing.sm + 4) {
            Group {
                if let progress {
                    KitoProgressRing(fraction: progress, size: 56, lineWidth: 5, color: color)
                } else {
                    KitoLoaderView(style: loader, color: color)
                }
            }
            .frame(minWidth: 56, minHeight: 56)
            if let message {
                Text(message)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.onSurface)
                    .multilineTextAlignment(.center)
            }
            if let detail {
                Text(detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.onSurface.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .frame(minWidth: 150, maxWidth: 260)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.18), lineWidth: 1))
        .shadow(color: .black.opacity(0.18), radius: 30, y: 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message ?? "Loading")
        .accessibilityValue(progress.map { "\(Int($0 * 100)) percent" } ?? "")
    }
}

struct KitoLoadingOverlayModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isPresented: Bool
    let message: String?
    let detail: String?
    let progress: Double?
    let loader: KitoLoaderStyle
    let blurRadius: CGFloat
    let dimming: Double

    func body(content: Content) -> some View {
        content
            .blur(radius: isPresented ? blurRadius : 0)
            .allowsHitTesting(!isPresented)
            .accessibilityHidden(isPresented)
            .overlay {
                if isPresented {
                    ZStack {
                        Color.black.opacity(dimming).ignoresSafeArea()
                        KitoLoadingCard(message: message, detail: detail, progress: progress, loader: loader)
                            .transition(reduceMotion ? .opacity : .scale(scale: 0.88).combined(with: .opacity))
                    }
                    .transition(.opacity)
                }
            }
            .animation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
    }
}

public extension View {
    /// Blurs and dims this view and floats a loading card over it while `isPresented`,
    /// blocking taps underneath — for a save, a payment or a sign-in the user must wait on.
    /// Pass `progress` (0...1) to show a determinate ring instead of a spinner.
    func kitoLoadingOverlay(isPresented: Bool, message: String? = nil, detail: String? = nil, progress: Double? = nil,
                            loader: KitoLoaderStyle = KitoLoaderStyle(kind: .gradientRing, size: 44, lineWidth: 4),
                            blurRadius: CGFloat = 8, dimming: Double = 0.2) -> some View {
        modifier(KitoLoadingOverlayModifier(isPresented: isPresented, message: message, detail: detail, progress: progress,
                                            loader: loader, blurRadius: blurRadius, dimming: dimming))
    }
}
