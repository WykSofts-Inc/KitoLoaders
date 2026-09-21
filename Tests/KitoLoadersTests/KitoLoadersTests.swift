//
//  KitoLoadersTests.swift
//  KitoLoaders
//
//  Created by Wycliff on 2/17/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
@testable import KitoLoaders
import KitoCore

final class KitoLoadersTests: XCTestCase {
    func testProgressRingClampsFraction() {
        let over = KitoProgressRing(fraction: 1.4)
        let under = KitoProgressRing(fraction: -0.2)
        XCTAssertEqual(over.fraction, 1.0)
        XCTAssertEqual(under.fraction, 0.0)
    }

    func testLoaderStyleDefaultsAreStable() {
        XCTAssertEqual(KitoLoaderStyle.default, KitoLoaderStyle())
        XCTAssertEqual(KitoLoaderStyle.default.kind, .spinner)
    }

    func testEveryLoaderKindHasADistinctKitoLoaderViewRendering() {
        // Not a visual assertion (that needs a running app) — this just
        // proves KitoLoaderView's switch is exhaustive and every kind
        // constructs without crashing, so adding a case without wiring the
        // switch fails the build, not a runtime surprise.
        let kinds: [KitoLoaderKind] = [.spinner, .dots, .pulse, .progressRing(fraction: 0.4), .skeleton, .bars, .wave, .ripple, .orbit, .gradientRing]
        for kind in kinds {
            _ = KitoLoaderView(style: KitoLoaderStyle(kind: kind))
        }
        XCTAssertEqual(kinds.count, 10)
    }
}
