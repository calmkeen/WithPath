//
//  LocationRecordingService.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

final class LocationRecordingService {
  private let provider: any LocationProviding
  private var recordingTask: Task<Void, Never>?

  init(provider: any LocationProviding) {
    self.provider = provider
  }

  func start(mode: LocationRecordingMode) {
    stop()

    recordingTask = Task {
      for await point in provider.locationUpdates(mode: mode) {
        _ = point
      }
    }
  }

  func stop() {
    recordingTask?.cancel()
    recordingTask = nil
  }
}
