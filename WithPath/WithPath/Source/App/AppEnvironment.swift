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

  static func live() -> AppEnvironment {
#if DEBUG
    if !UserDefaults.standard.bool(forKey: "WithPath.useRealLocation") {
      return AppEnvironment(
        configuration: .debugMock,
        locationProvider: MockLocationProvider(),
        locationPermissionService: MockLocationPermissionService()
      )
    }
#endif

    return AppEnvironment(
      configuration: .live,
      locationProvider: CoreLocationProvider(),
      locationPermissionService: LocationPermissionService()
    )
  }

  static func preview() -> AppEnvironment {
    AppEnvironment(
      configuration: .debugMock,
      locationProvider: StaticLocationProvider(),
      locationPermissionService: MockLocationPermissionService()
    )
  }
}
