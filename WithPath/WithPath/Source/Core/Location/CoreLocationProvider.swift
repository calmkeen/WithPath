//
//  CoreLocationProvider.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import CoreLocation
import Foundation

final class CoreLocationProvider: LocationProviding {
  func locationUpdates(configuration: LocationRecordingConfiguration) -> AsyncStream<LocationPoint> {
    AsyncStream { continuation in
      let task = Task {
        do {
          for try await update in CLLocationUpdate.liveUpdates(configuration.liveConfiguration) {
            guard !Task.isCancelled else { break }
            guard let location = update.location else { continue }

            guard location.horizontalAccuracy <= configuration.desiredAccuracyMeters else { continue }
            continuation.yield(LocationPoint(location: location))
          }
        } catch {
          // Permission, service, or cancellation errors should stop this stream cleanly.
        }

        continuation.finish()
      }

      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }
}
