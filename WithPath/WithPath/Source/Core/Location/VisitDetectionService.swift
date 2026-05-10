//
//  VisitDetectionService.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation
import CoreLocation

struct VisitDetectionConfiguration: Equatable, Sendable {
  var dwellRadiusMeters: CLLocationDistance
  var dwellThresholdSeconds: TimeInterval
  var maximumHorizontalAccuracyMeters: Double
  var minimumPointCount: Int
  var maximumPointGapSeconds: TimeInterval
  var mergeGapSeconds: TimeInterval

  init(
    dwellRadiusMeters: CLLocationDistance = 80,
    dwellThresholdSeconds: TimeInterval = 10 * 60,
    maximumHorizontalAccuracyMeters: Double = 120,
    minimumPointCount: Int = 3,
    maximumPointGapSeconds: TimeInterval = 15 * 60,
    mergeGapSeconds: TimeInterval = 10 * 60
  ) {
    self.dwellRadiusMeters = dwellRadiusMeters
    self.dwellThresholdSeconds = dwellThresholdSeconds
    self.maximumHorizontalAccuracyMeters = maximumHorizontalAccuracyMeters
    self.minimumPointCount = minimumPointCount
    self.maximumPointGapSeconds = maximumPointGapSeconds
    self.mergeGapSeconds = mergeGapSeconds
  }
}

struct DetectedVisit: Identifiable, Equatable, Sendable {
  let id: UUID
  var centerPoint: LocationPoint
  var startedAt: Date
  var endedAt: Date
  var durationSeconds: TimeInterval
  var sourcePointCount: Int
  var confidence: Double

  init(
    id: UUID = UUID(),
    centerPoint: LocationPoint,
    startedAt: Date,
    endedAt: Date,
    sourcePointCount: Int,
    confidence: Double
  ) {
    self.id = id
    self.centerPoint = centerPoint
    self.startedAt = startedAt
    self.endedAt = endedAt
    durationSeconds = endedAt.timeIntervalSince(startedAt)
    self.sourcePointCount = sourcePointCount
    self.confidence = confidence
  }
}

struct VisitDetectionService {
  let configuration: VisitDetectionConfiguration

  init(configuration: VisitDetectionConfiguration = VisitDetectionConfiguration()) {
    self.configuration = configuration
  }

  func detectVisits(from points: [LocationPoint]) -> [DetectedVisit] {
    let usablePoints = points
      .filter { $0.horizontalAccuracy <= configuration.maximumHorizontalAccuracyMeters }
      .sorted { $0.capturedAt < $1.capturedAt }

    guard usablePoints.count >= configuration.minimumPointCount else {
      return []
    }

    var clusters: [[LocationPoint]] = []
    var currentCluster: [LocationPoint] = []

    for point in usablePoints {
      guard let previousPoint = currentCluster.last else {
        currentCluster = [point]
        continue
      }

      let timeGap = point.capturedAt.timeIntervalSince(previousPoint.capturedAt)
      let center = centerPoint(for: currentCluster)
      let distanceFromCenter = distanceMeters(from: center, to: point)

      if timeGap <= configuration.maximumPointGapSeconds &&
        distanceFromCenter <= configuration.dwellRadiusMeters {
        currentCluster.append(point)
      } else {
        clusters.append(currentCluster)
        currentCluster = [point]
      }
    }

    if !currentCluster.isEmpty {
      clusters.append(currentCluster)
    }

    let visits = clusters.compactMap(makeDetectedVisit(from:))
    return mergeNearbyVisits(visits)
  }

  private func makeDetectedVisit(from points: [LocationPoint]) -> DetectedVisit? {
    guard
      points.count >= configuration.minimumPointCount,
      let firstPoint = points.first,
      let lastPoint = points.last
    else {
      return nil
    }

    let duration = lastPoint.capturedAt.timeIntervalSince(firstPoint.capturedAt)
    guard duration >= configuration.dwellThresholdSeconds else {
      return nil
    }

    let centerPoint = centerPoint(for: points)
    let averageAccuracy = points.map(\.horizontalAccuracy).reduce(0, +) / Double(points.count)

    return DetectedVisit(
      centerPoint: centerPoint,
      startedAt: firstPoint.capturedAt,
      endedAt: lastPoint.capturedAt,
      sourcePointCount: points.count,
      confidence: confidence(
        durationSeconds: duration,
        pointCount: points.count,
        averageAccuracy: averageAccuracy
      )
    )
  }

  private func mergeNearbyVisits(_ visits: [DetectedVisit]) -> [DetectedVisit] {
    visits.reduce(into: []) { mergedVisits, visit in
      guard let lastVisit = mergedVisits.last else {
        mergedVisits.append(visit)
        return
      }

      let gap = visit.startedAt.timeIntervalSince(lastVisit.endedAt)
      let distance = distanceMeters(from: lastVisit.centerPoint, to: visit.centerPoint)

      guard gap <= configuration.mergeGapSeconds &&
        distance <= configuration.dwellRadiusMeters else {
        mergedVisits.append(visit)
        return
      }

      mergedVisits[mergedVisits.count - 1] = mergedVisit(lastVisit, visit)
    }
  }

  private func mergedVisit(_ firstVisit: DetectedVisit, _ secondVisit: DetectedVisit) -> DetectedVisit {
    let totalCount = firstVisit.sourcePointCount + secondVisit.sourcePointCount
    let latitude = weightedAverage(
      firstVisit.centerPoint.latitude,
      firstVisit.sourcePointCount,
      secondVisit.centerPoint.latitude,
      secondVisit.sourcePointCount
    )
    let longitude = weightedAverage(
      firstVisit.centerPoint.longitude,
      firstVisit.sourcePointCount,
      secondVisit.centerPoint.longitude,
      secondVisit.sourcePointCount
    )
    let horizontalAccuracy = weightedAverage(
      firstVisit.centerPoint.horizontalAccuracy,
      firstVisit.sourcePointCount,
      secondVisit.centerPoint.horizontalAccuracy,
      secondVisit.sourcePointCount
    )
    let centerPoint = LocationPoint(
      id: firstVisit.centerPoint.id,
      latitude: latitude,
      longitude: longitude,
      horizontalAccuracy: horizontalAccuracy,
      speed: nil,
      capturedAt: firstVisit.startedAt
    )

    return DetectedVisit(
      id: firstVisit.id,
      centerPoint: centerPoint,
      startedAt: firstVisit.startedAt,
      endedAt: secondVisit.endedAt,
      sourcePointCount: totalCount,
      confidence: max(firstVisit.confidence, secondVisit.confidence)
    )
  }

  private func centerPoint(for points: [LocationPoint]) -> LocationPoint {
    let pointCount = Double(points.count)
    let latitude = points.map(\.latitude).reduce(0, +) / pointCount
    let longitude = points.map(\.longitude).reduce(0, +) / pointCount
    let accuracy = points.map(\.horizontalAccuracy).reduce(0, +) / pointCount

    return LocationPoint(
      id: points.first?.id ?? UUID(),
      latitude: latitude,
      longitude: longitude,
      horizontalAccuracy: accuracy,
      speed: nil,
      capturedAt: points.first?.capturedAt ?? .now
    )
  }

  private func confidence(
    durationSeconds: TimeInterval,
    pointCount: Int,
    averageAccuracy: Double
  ) -> Double {
    let durationScore = min(durationSeconds / configuration.dwellThresholdSeconds, 1)
    let countScore = min(Double(pointCount) / Double(configuration.minimumPointCount + 2), 1)
    let accuracyScore = max(
      0,
      1 - (averageAccuracy / configuration.maximumHorizontalAccuracyMeters)
    )

    let score = durationScore * 0.45 + countScore * 0.35 + accuracyScore * 0.20
    return min(max(score, 0), 1)
  }

  private func distanceMeters(from firstPoint: LocationPoint, to secondPoint: LocationPoint) -> CLLocationDistance {
    let firstLocation = CLLocation(latitude: firstPoint.latitude, longitude: firstPoint.longitude)
    let secondLocation = CLLocation(latitude: secondPoint.latitude, longitude: secondPoint.longitude)
    return secondLocation.distance(from: firstLocation)
  }

  private func weightedAverage(
    _ firstValue: Double,
    _ firstCount: Int,
    _ secondValue: Double,
    _ secondCount: Int
  ) -> Double {
    let totalCount = Double(firstCount + secondCount)
    return (firstValue * Double(firstCount) + secondValue * Double(secondCount)) / totalCount
  }
}
