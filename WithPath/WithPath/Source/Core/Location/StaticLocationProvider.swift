//
//  StaticLocationProvider.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

final class StaticLocationProvider: LocationProviding {
  func locationUpdates(mode: LocationRecordingMode) -> AsyncStream<LocationPoint> {
    AsyncStream { continuation in
      continuation.yield(
        LocationPoint(latitude: 37.5665, longitude: 126.9780, horizontalAccuracy: 25, speed: nil)
      )
      continuation.finish()
    }
  }
}
