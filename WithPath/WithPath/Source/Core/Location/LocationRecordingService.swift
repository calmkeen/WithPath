//
//  LocationRecordingService.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation
import CoreLocation
import os

protocol LocationRecordingServicing: AnyObject {
  var snapshot: LocationRecordingSnapshot { get }
  var onSnapshotChange: ((LocationRecordingSnapshot) -> Void)? { get set }

  func start(mode: LocationRecordingMode)
  func stop()
}

final class LocationRecordingService: LocationRecordingServicing {
  private let provider: any LocationProviding
  private let traceRepository: (any TraceRepository)?
  private let visitRepository: (any VisitRepository)?
  private let visitDetectionService: VisitDetectionService
  private let logger = Logger(subsystem: "com.calmkeen.WithPath", category: "location")
  private var recordingTask: Task<Void, Never>?
  private var lastAcceptedPoint: LocationPoint?
  private var sessionPoints: [LocationPoint] = []

  private(set) var snapshot: LocationRecordingSnapshot = .idle {
    didSet {
      onSnapshotChange?(snapshot)
    }
  }

  var onSnapshotChange: ((LocationRecordingSnapshot) -> Void)?

  init(
    provider: any LocationProviding,
    traceRepository: (any TraceRepository)? = nil,
    visitRepository: (any VisitRepository)? = nil,
    visitDetectionService: VisitDetectionService = VisitDetectionService()
  ) {
    self.provider = provider
    self.traceRepository = traceRepository
    self.visitRepository = visitRepository
    self.visitDetectionService = visitDetectionService
  }

  func start(mode: LocationRecordingMode) {
    guard mode != .off else {
      stop()
      return
    }

    stop()

    let configuration = LocationRecordingConfiguration.configuration(for: mode)
    lastAcceptedPoint = nil
    sessionPoints = []
    snapshot = LocationRecordingSnapshot(
      mode: mode,
      isRecording: true,
      startedAt: .now,
      stoppedAt: nil,
      lastPoint: nil,
      receivedPointCount: 0
    )

    recordingTask = Task {
      for await point in provider.locationUpdates(configuration: configuration) {
        sessionPoints.append(point)
        guard accepts(point, configuration: configuration) else { continue }

        lastAcceptedPoint = point
        snapshot.lastPoint = point
        snapshot.receivedPointCount += 1

        await saveTraceIfNeeded(point, configuration: configuration)
      }
    }
  }

  func stop() {
    recordingTask?.cancel()
    recordingTask = nil

    guard snapshot.isRecording else {
      lastAcceptedPoint = nil
      sessionPoints = []
      return
    }

    let pointsForVisitDetection = sessionPoints
    lastAcceptedPoint = nil
    sessionPoints = []

    snapshot.isRecording = false
    snapshot.mode = .off
    snapshot.stoppedAt = .now

    Task {
      await saveDetectedVisits(from: pointsForVisitDetection)
    }
  }

  private func accepts(
    _ point: LocationPoint,
    configuration: LocationRecordingConfiguration
  ) -> Bool {
    guard let lastAcceptedPoint else { return true }

    let previousLocation = CLLocation(
      latitude: lastAcceptedPoint.latitude,
      longitude: lastAcceptedPoint.longitude
    )
    let currentLocation = CLLocation(latitude: point.latitude, longitude: point.longitude)

    return currentLocation.distance(from: previousLocation) >= configuration.distanceFilterMeters
  }

  private func saveTraceIfNeeded(
    _ point: LocationPoint,
    configuration: LocationRecordingConfiguration
  ) async {
    guard let traceRepository else { return }

    let trace = TraceRecord(
      id: point.id,
      point: point,
      isLowConfidence: point.horizontalAccuracy > configuration.desiredAccuracyMeters
    )

    do {
      try await traceRepository.save(trace)
    } catch {
      logger.error("Failed to save trace: \(error.localizedDescription, privacy: .public)")
#if DEBUG
      print("[WithPath][DB] Failed to save trace: \(error.localizedDescription)")
#endif
    }
  }

  private func saveDetectedVisits(from points: [LocationPoint]) async {
    guard let visitRepository else { return }

    let visits = visitDetectionService.detectVisits(from: points)
    guard !visits.isEmpty else { return }

    do {
      try await visitRepository.save(visits)
    } catch {
      logger.error("Failed to save visits: \(error.localizedDescription, privacy: .public)")
#if DEBUG
      print("[WithPath][DB] Failed to save visits: \(error.localizedDescription)")
#endif
    }
  }
}

final class MockLocationRecordingService: LocationRecordingServicing {
  private(set) var snapshot: LocationRecordingSnapshot = .idle {
    didSet {
      onSnapshotChange?(snapshot)
    }
  }

  var onSnapshotChange: ((LocationRecordingSnapshot) -> Void)?

  func start(mode: LocationRecordingMode) {
    snapshot = LocationRecordingSnapshot(
      mode: mode,
      isRecording: mode != .off,
      startedAt: mode == .off ? nil : .now,
      stoppedAt: nil,
      lastPoint: LocationPoint(
        latitude: 37.5665,
        longitude: 126.9780,
        horizontalAccuracy: 24,
        speed: 1.1
      ),
      receivedPointCount: mode == .off ? 0 : 1
    )
  }

  func stop() {
    snapshot.isRecording = false
    snapshot.mode = .off
    snapshot.stoppedAt = .now
  }
}
