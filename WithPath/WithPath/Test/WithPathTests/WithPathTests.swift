//
//  WithPathTests.swift
//  WithPathTests
//
//  Created by calmkeen on 4/26/26.
//

import XCTest
@testable import WithPath

final class WithPathTests: XCTestCase {
  private let baseDate = Date(timeIntervalSince1970: 1_800_000_000)

  func testVisitDetectionFindsStationaryDwell() {
    let service = VisitDetectionService()

    let visits = service.detectVisits(
      from: [
        point(latitudeOffset: 0, longitudeOffset: 0, minutesAfterStart: 0),
        point(latitudeOffset: 0.00008, longitudeOffset: 0.00004, minutesAfterStart: 5),
        point(latitudeOffset: -0.00004, longitudeOffset: 0.00005, minutesAfterStart: 11)
      ]
    )

    XCTAssertEqual(visits.count, 1)
    XCTAssertEqual(visits[0].sourcePointCount, 3)
    XCTAssertEqual(visits[0].durationSeconds, 11 * 60, accuracy: 0.1)
    XCTAssertGreaterThan(visits[0].confidence, 0.7)
  }

  func testVisitDetectionIgnoresMovingTrace() {
    let service = VisitDetectionService()

    let visits = service.detectVisits(
      from: [
        point(latitudeOffset: 0, longitudeOffset: 0, minutesAfterStart: 0),
        point(latitudeOffset: 0.002, longitudeOffset: 0.002, minutesAfterStart: 5),
        point(latitudeOffset: 0.004, longitudeOffset: 0.004, minutesAfterStart: 11),
        point(latitudeOffset: 0.006, longitudeOffset: 0.006, minutesAfterStart: 18)
      ]
    )

    XCTAssertTrue(visits.isEmpty)
  }

  func testVisitDetectionIgnoresLowAccuracyPoints() {
    let service = VisitDetectionService()

    let visits = service.detectVisits(
      from: [
        point(latitudeOffset: 0, longitudeOffset: 0, minutesAfterStart: 0, accuracy: 250),
        point(latitudeOffset: 0.00004, longitudeOffset: 0, minutesAfterStart: 5, accuracy: 240),
        point(latitudeOffset: 0.00003, longitudeOffset: 0.00004, minutesAfterStart: 11, accuracy: 260)
      ]
    )

    XCTAssertTrue(visits.isEmpty)
  }

  func testVisitDetectionSplitsDistantDwellClusters() {
    let service = VisitDetectionService()

    let visits = service.detectVisits(
      from: [
        point(latitudeOffset: 0, longitudeOffset: 0, minutesAfterStart: 0),
        point(latitudeOffset: 0.00008, longitudeOffset: 0.00004, minutesAfterStart: 5),
        point(latitudeOffset: -0.00004, longitudeOffset: 0.00005, minutesAfterStart: 11),
        point(latitudeOffset: 0.01, longitudeOffset: 0.01, minutesAfterStart: 22),
        point(latitudeOffset: 0.01004, longitudeOffset: 0.01006, minutesAfterStart: 28),
        point(latitudeOffset: 0.01002, longitudeOffset: 0.01002, minutesAfterStart: 34)
      ]
    )

    XCTAssertEqual(visits.count, 2)
    XCTAssertLessThan(visits[0].centerPoint.latitude, visits[1].centerPoint.latitude)
  }

  private func point(
    latitudeOffset: Double,
    longitudeOffset: Double,
    minutesAfterStart: TimeInterval,
    accuracy: Double = 15
  ) -> LocationPoint {
    LocationPoint(
      latitude: 37.5665 + latitudeOffset,
      longitude: 126.9780 + longitudeOffset,
      horizontalAccuracy: accuracy,
      speed: nil,
      capturedAt: baseDate.addingTimeInterval(minutesAfterStart * 60)
    )
  }
}
