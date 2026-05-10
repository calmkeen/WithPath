//
//  MockLocationProvider.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

#if DEBUG
final class MockLocationProvider: LocationProviding {
  func locationUpdates(configuration: LocationRecordingConfiguration) -> AsyncStream<LocationPoint> {
    let baseDate = Date.now.addingTimeInterval(-13 * 60)
    let samplePoints = [
      LocationPoint(
        latitude: 37.5665,
        longitude: 126.9780,
        horizontalAccuracy: 24,
        speed: 0.2,
        capturedAt: baseDate
      ),
      LocationPoint(
        latitude: 37.56656,
        longitude: 126.97805,
        horizontalAccuracy: 18,
        speed: 0.1,
        capturedAt: baseDate.addingTimeInterval(5 * 60)
      ),
      LocationPoint(
        latitude: 37.56652,
        longitude: 126.97808,
        horizontalAccuracy: 16,
        speed: 0.1,
        capturedAt: baseDate.addingTimeInterval(11 * 60)
      ),
      LocationPoint(
        latitude: 37.5680,
        longitude: 126.9814,
        horizontalAccuracy: 20,
        speed: 1.4,
        capturedAt: baseDate.addingTimeInterval(13 * 60)
      )
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
