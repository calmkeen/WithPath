//
//  LocationRecordingConfiguration.swift
//  WithPath
//
//  Created by calmkeen on 5/3/26.
//

import CoreLocation
import Foundation

struct LocationRecordingConfiguration: Equatable, Sendable {
  let mode: LocationRecordingMode
  let liveConfiguration: CLLocationUpdate.LiveConfiguration
  let desiredAccuracyMeters: Double
  let distanceFilterMeters: Double
  let allowsBackgroundUpdates: Bool
  let pausesAutomatically: Bool

  static func configuration(for mode: LocationRecordingMode) -> LocationRecordingConfiguration {
    switch mode {
    case .off:
      return LocationRecordingConfiguration(
        mode: mode,
        liveConfiguration: .default,
        desiredAccuracyMeters: 1_000,
        distanceFilterMeters: 500,
        allowsBackgroundUpdates: false,
        pausesAutomatically: true
      )
    case .balanced:
      return LocationRecordingConfiguration(
        mode: mode,
        liveConfiguration: .default,
        desiredAccuracyMeters: 100,
        distanceFilterMeters: 80,
        allowsBackgroundUpdates: true,
        pausesAutomatically: true
      )
    case .precise:
      return LocationRecordingConfiguration(
        mode: mode,
        liveConfiguration: .otherNavigation,
        desiredAccuracyMeters: 25,
        distanceFilterMeters: 20,
        allowsBackgroundUpdates: true,
        pausesAutomatically: false
      )
    case .stationary:
      return LocationRecordingConfiguration(
        mode: mode,
        liveConfiguration: .default,
        desiredAccuracyMeters: 250,
        distanceFilterMeters: 150,
        allowsBackgroundUpdates: true,
        pausesAutomatically: true
      )
    case .shareLive:
      return LocationRecordingConfiguration(
        mode: mode,
        liveConfiguration: .otherNavigation,
        desiredAccuracyMeters: 15,
        distanceFilterMeters: 10,
        allowsBackgroundUpdates: true,
        pausesAutomatically: false
      )
    }
  }
}
