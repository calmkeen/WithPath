//
//  AppEnvironment.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

struct AppEnvironment {
  let configuration: AppConfiguration
  let locationProvider: any LocationProviding
  let locationPermissionService: any LocationPermissionServicing
  let locationRecordingService: any LocationRecordingServicing

  static func live() -> AppEnvironment {
#if DEBUG
    if !UserDefaults.standard.bool(forKey: "WithPath.useRealLocation") {
      let provider = MockLocationProvider()
      return AppEnvironment(
        configuration: .debugMock,
        locationProvider: provider,
        locationPermissionService: MockLocationPermissionService(),
        locationRecordingService: LocationRecordingService(provider: provider)
      )
    }
#endif

    let provider = CoreLocationProvider()
    return AppEnvironment(
      configuration: .live,
      locationProvider: provider,
      locationPermissionService: LocationPermissionService(),
      locationRecordingService: LocationRecordingService(provider: provider)
    )
  }

  static func preview() -> AppEnvironment {
    let provider = StaticLocationProvider()
    return AppEnvironment(
      configuration: .debugMock,
      locationProvider: provider,
      locationPermissionService: MockLocationPermissionService(),
      locationRecordingService: MockLocationRecordingService()
    )
  }
}
