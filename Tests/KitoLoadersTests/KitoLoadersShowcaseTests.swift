//
//  KitoLoadersShowcaseTests.swift
//  KitoLoaders
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
@testable import KitoLoaders

final class KitoLoadersShowcaseTests: XCTestCase {
    func testShimmerPhaseWrapsAndOffsetSpansTheView() {
        XCTAssertEqual(KitoShimmerMath.phase(at: 3.5, duration: 1), 0.5, accuracy: 0.0001)
        XCTAssertEqual(KitoShimmerMath.offset(phase: 0, width: 200, band: 80), -80)
        XCTAssertEqual(KitoShimmerMath.offset(phase: 1, width: 200, band: 80), 280)
    }

    func testSkeletonLineFractionsAreStableAndInRange() {
        for row in 0..<20 {
            for line in 0..<4 {
                let fraction = KitoSkeletonTemplate.lineFraction(row: row, line: line)
                XCTAssertGreaterThanOrEqual(fraction, 0.55)
                XCTAssertLessThanOrEqual(fraction, 1)
                XCTAssertEqual(fraction, KitoSkeletonTemplate.lineFraction(row: row, line: line))
            }
        }
        XCTAssertNotEqual(KitoSkeletonTemplate.lineFraction(row: 0, line: 0), KitoSkeletonTemplate.lineFraction(row: 1, line: 0))
    }

    func testEveryTemplateBuilds() {
        for template in KitoSkeletonTemplate.allCases {
            _ = KitoSkeletonView(template, count: 3)
        }
        XCTAssertEqual(KitoSkeletonTemplate.allCases.count, 7)
    }

    func testMorphFormsRadii() {
        XCTAssertEqual(KitoMorphForm.circle.radius(at: 0.7), 1)
        // A flat-topped square is 1 at its corners and cos(45°) at the middle of each side.
        XCTAssertEqual(KitoMorphForm.square.radius(at: -.pi / 2), cos(.pi / 4), accuracy: 0.0001)
        XCTAssertEqual(KitoMorphForm.square.radius(at: -.pi / 4), 1, accuracy: 0.0001)
        XCTAssertEqual(KitoMorphForm.triangle.radius(at: -.pi / 2), 1, accuracy: 0.0001)
        XCTAssertEqual(KitoMorphForm.star.radius(at: -.pi / 2 + .pi / 5), 0.5, accuracy: 0.0001)
        for form in KitoMorphForm.allCases {
            for step in 0..<36 {
                let radius = form.radius(at: Double(step) * .pi / 18)
                XCTAssertGreaterThan(radius, 0.3, "\(form)")
                XCTAssertLessThanOrEqual(radius, 1.0001, "\(form)")
            }
        }
    }

    func testMorphBlendsBetweenForms() {
        let halfway = KitoMorphShape.radius(from: .circle, to: .square, progress: 0.5, softness: 0, angle: -.pi / 2)
        XCTAssertEqual(halfway, (1 + cos(.pi / 4)) / 2, accuracy: 0.0001)
    }

    func testMorphStepHoldsThenEases() {
        let hold = KitoMorphingLoader.step(at: 0.2, stepDuration: 1, count: 3)
        XCTAssertEqual(hold.index, 0)
        XCTAssertEqual(hold.progress, 0)
        let later = KitoMorphingLoader.step(at: 2.99, stepDuration: 1, count: 3)
        XCTAssertEqual(later.index, 2)
        XCTAssertGreaterThan(later.progress, 0.95)
    }

    func testIndeterminateSegmentsStayOnTheTrack() {
        for step in 0...100 {
            for index in 0..<2 {
                let segment = KitoLinearProgress.segment(phase: Double(step) / 100, index: index)
                XCTAssertGreaterThanOrEqual(segment.start, 0)
                XCTAssertLessThanOrEqual(segment.end, 1)
                XCTAssertLessThanOrEqual(segment.start, segment.end + 0.0001)
            }
        }
    }

    func testLinearProgressClampsFraction() {
        XCTAssertEqual(KitoLinearProgress(fraction: 1.7).fraction, 1)
        XCTAssertNil(KitoLinearProgress().fraction)
    }

    func testStepProgressClampsAndFillsSegments() {
        XCTAssertEqual(KitoStepProgress.clampedStep(9, count: 4), 4)
        XCTAssertEqual(KitoStepProgress.clampedStep(-2, count: 4), 0)
        XCTAssertEqual(KitoStepProgress.segmentFill(index: 0, current: 2, fraction: 0.3), 1)
        XCTAssertEqual(KitoStepProgress.segmentFill(index: 2, current: 2, fraction: 0.3), 0.3)
        XCTAssertEqual(KitoStepProgress.segmentFill(index: 3, current: 2, fraction: 0.3), 0)
    }

    func testRefreshProgress() {
        XCTAssertEqual(KitoRefreshMath.progress(offset: 40, threshold: 80), 0.5)
        XCTAssertEqual(KitoRefreshMath.progress(offset: 200, threshold: 80), 1)
        XCTAssertEqual(KitoRefreshMath.progress(offset: -20, threshold: 80), 0)
    }

    func testTypingDotsHopInTurn() {
        XCTAssertGreaterThan(KitoTypingIndicator.lift(at: 0.2, index: 0), 0.5)
        XCTAssertEqual(KitoTypingIndicator.lift(at: 0.2, index: 2), 0)
        XCTAssertEqual(KitoTypingIndicator.lift(at: 1.15, index: 0), 0)
    }

    func testECGPeaksAtTheRWave() {
        let peak = (0...100).map { KitoHeartbeatLoader.ecg(Double($0) / 100) }.enumerated().max { $0.element < $1.element }
        XCTAssertEqual(peak?.offset, 38)
        XCTAssertEqual(KitoHeartbeatLoader.ecg(0.95), 0, accuracy: 0.01)
    }
}
