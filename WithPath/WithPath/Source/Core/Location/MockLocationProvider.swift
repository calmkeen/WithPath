//
//  MockLocationProvider.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

#if DEBUG
final class MockLocationProvider: LocationProviding {
  func locationUpdates(mode: LocationRecordingMode) -> AsyncStream<LocationPoint> {
    let samplePoints = [
      LocationPoint(latitude: 37.5665, longitude: 126.9780, horizontalAccuracy: 24, speed: 1.1),
      LocationPoint(latitude: 37.5669, longitude: 126.9791, horizontalAccuracy: 18, speed: 1.4),
      LocationPoint(latitude: 37.5674, longitude: 126.9802, horizontalAccuracy: 16, speed: 1.2),
      LocationPoint(latitude: 37.5680, longitude: 126.9814, horizontalAccuracy: 20, speed: 0.9)
    ]

    return AsyncStream { continuation in
      let task = Task {
        for point in samplePoints {
          guard !Task.isCancelled else { break }
          continuation.yield(point)
          try? await Task.sleep(for: .seconds(2))
        }

        continuation.finish()
      }

      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }
}
#endif
