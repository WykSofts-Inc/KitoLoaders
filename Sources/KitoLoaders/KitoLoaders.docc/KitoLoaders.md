# ``KitoLoaders``

Themeable loading indicators, progress views and skeleton placeholders for SwiftUI.

## Overview

KitoLoaders provides spinners, dots, pulses, determinate and indeterminate
progress, step progress, skeleton placeholders, a blocking loading overlay and a
pull-to-refresh scroll view. Every loader reads its colors from KitoCore's
`kitoTheme` and accepts an optional `color:` override; omit it to use
`@Environment(\.kitoTheme).colors.primary`.

```swift
import KitoLoaders

KitoSpinner()
KitoProgressRing(fraction: 0.6)
KitoSkeletonView(.listRow, count: 5)

Text(article.title)
    .kitoSkeleton(isLoading: viewModel.state.isLoading)

CheckoutView()
    .kitoLoadingOverlay(isPresented: isPaying, message: "Confirming payment")
```

When several screens should follow one app-wide choice of loader, pass a
`KitoLoaderStyle` (declared in KitoCore) to ``KitoLoaderView`` instead of picking
a concrete loader type at each call site. The view modifiers `kitoSkeleton`,
`kitoRedacted`, `kitoShimmer` and `kitoLoadingOverlay` cover placeholder and
blocking states for existing views.

## Topics

### Essentials

- ``KitoLoaderView``
- ``KitoSpinner``

### Indeterminate Loaders

- ``KitoDotsLoader``
- ``KitoPulseLoader``
- ``KitoBarsLoader``
- ``KitoWaveLoader``
- ``KitoOrbitLoader``
- ``KitoRippleLoader``
- ``KitoGradientRingLoader``
- ``KitoHeartbeatLoader``
- ``KitoMorphingLoader``
- ``KitoMorphForm``
- ``KitoTypingIndicator``

### Progress

- ``KitoProgressRing``
- ``KitoLinearProgress``
- ``KitoStepProgress``

### Skeletons

- ``KitoSkeleton``
- ``KitoSkeletonView``
- ``KitoSkeletonTemplate``

### Overlays and Refresh

- ``KitoLoadingCard``
- ``KitoRefreshIndicator``
- ``KitoRefreshableScrollView``
