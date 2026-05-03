//
//  LocationRecordingService.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation
import CoreLocation

protocol LocationRecordingServicing: AnyObject {
  var snapshot: LocationRecordingSnapshot { get }
  var onSnapshotChange: ((LocationRecordingSnapshot) -> Void)? { get set }

  func start(mode: LocationRecordingMode)
  func stop()
}

final class LocationRecordingService: LocationRecordingServicing {
  private let provider: any LocationProviding
  private var recordingTask: Task<Void, Never>?
  private var lastAcceptedPoint: LocationPoint?

  private(set) var snapshot: LocationRecordingSnapshot = .idle {
    didSet {
      onSnapshotChange?(snapshot)
    }
  }

  var onSnapshotChange: ((LocationRecordingSnapshot) -> Void)?

  init(provider: any LocationProviding) {
    self.provider = provider
  }

  func start(mode: LocationRecordingMode) {
    guard mode != .off else {
      stop()
      return
    }

    stop()

    let configuration = LocationRecordingConfiguration.configuration(for: mode)
    lastAcceptedPoint = nil
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
        guard accepts(point, configuration: configuration) else { continue }

        lastAcceptedPoint = point
        snapshot.lastPoint = point
        snapshot.receivedPointCount += 1
      }
    }
  }

  func stop() {
    recordingTask?.cancel()
    recordingTask = nil
    lastAcceptedPoint = nil

    guard snapshot.isRecording else { return }

    snapshot.isRecording = false
    snapshot.mode = .off
    snapshot.stoppedAt = .now
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
