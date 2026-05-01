//
//  LocationPermissionService.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import CoreLocation
import Foundation

final class LocationPermissionService {
  private let manager = CLLocationManager()

  var authorizationStatus: CLAuthorizationStatus {
    manager.authorizationStatus
  }

  func requestWhenInUseAuthorization() {
    manager.requestWhenInUseAuthorization()
  }

  func requestAlwaysAuthorization() {
    manager.requestAlwaysAuthorization()
  }
}
