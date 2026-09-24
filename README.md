# KitoLoaders

**[Documentation](https://wyksofts-inc.github.io/KitoLoaders/documentation/kitoloaders/)**

Custom, themeable loading indicators for SwiftUI: spinner, dots, pulse,
determinate progress ring, and skeleton placeholders — all reading colors
from `KitoCore`'s `kitoTheme` so they match the rest of the ecosystem for free.

## Install

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoLoaders.git", from: "1.1.0"),
```

## Use

```swift
import KitoLoaders

KitoSpinner()
KitoDotsLoader()
KitoPulseLoader()
KitoProgressRing(fraction: 0.6)

// Skeleton placeholder for a specific view
Text(article.title)
    .kitoSkeleton(isLoading: viewModel.state.isLoading)

// Style-driven (pick the kind via configuration, e.g. from a screen parameter)
KitoLoaderView(style: KitoLoaderStyle(kind: .dots, size: 30))
```

## Skeletons

```swift
// Ready-made layouts, shimmering in one sweep
KitoSkeletonView(.listRow, count: 5)
KitoSkeletonView(.feedPost)          // also .card, .profile, .chat, .grid, .article

// Redact real content into shimmering placeholders
TransactionRow(transaction)
    .kitoRedacted(isLoading: viewModel.isLoading)

// Shimmer any shape
RoundedRectangle(cornerRadius: 12).fill(.gray.opacity(0.2)).kitoShimmer()
```

## More loaders

```swift
KitoTypingIndicator()                       // chat bubble with hopping dots
KitoHeartbeatLoader(showsHeart: true)       // ECG trace with a beating heart
KitoMorphingLoader(forms: [.circle, .star]) // shape-shifting blob
KitoLinearProgress()                        // indeterminate bar
KitoLinearProgress(fraction: 0.62, label: "Uploading", showsPercentage: true)
KitoStepProgress(steps: ["Cart", "Delivery", "Pay"], current: 1)
KitoStepProgress(steps: stories, current: 2, stepFraction: 0.4, style: .segments)
```

## Blocking overlay

```swift
CheckoutView()
    .kitoLoadingOverlay(isPresented: isPaying, message: "Confirming payment", detail: "Check your phone for the prompt")
```

## Pull to refresh

```swift
KitoRefreshableScrollView(onRefresh: { await viewModel.reload() }) {
    LazyVStack { ForEach(items) { ItemRow($0) } }
}
```

Every loader accepts an optional `color:` override; omit it to use
`@Environment(\.kitoTheme).colors.primary`.

## Why a style enum (`KitoLoaderStyle`) at all

`KitoScreens` and other consumers often want "whichever loader the app
chose" as a single configuration value threaded through several screens,
rather than picking a concrete `KitoSpinner` vs `KitoDotsLoader` type at each
call site. `KitoLoaderStyle` (in KitoCore) + `KitoLoaderView` (here) is that
indirection — set it once, every screen using `KitoLoaderView` follows.

## License

MIT
