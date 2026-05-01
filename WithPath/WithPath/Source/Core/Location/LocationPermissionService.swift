//
//  LocationPermissionService.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import CoreLocation
import Foundation

protocol LocationPermissionServicing: AnyObject {
  var authorizationStatus: LocationAuthorizationStatus { get }
  var onAuthorizationChange: ((LocationAuthorizationStatus) -> Void)? { get set }

  func refreshAuthorizationStatus()
  func requestWhenInUseAuthorization()
  func requestAlwaysAuthorization()
}

final class LocationPermissionService: NSObject, LocationPermissionServicing {
  private let manager: CLLocationManager

  private(set) var authorizationStatus: LocationAuthorizationStatus
  var onAuthorizationChange: ((LocationAuthorizationStatus) -> Void)?

  override init() {
    let manager = CLLocationManager()
    self.manager = manager
    authorizationStatus = LocationAuthorizationStatus(manager.authorizationStatus)
    super.init()
    self.manager.delegate = self
  }

  func refreshAuthorizationStatus() {
    updateAuthorizationStatus(manager.authorizationStatus)
  }

  func requestWhenInUseAuthorization() {
    manager.requestWhenInUseAuthorization()
  }

  func requestAlwaysAuthorization() {
    manager.requestAlwaysAuthorization()
  }

  private func updateAuthorizationStatus(_ status: CLAuthorizationStatus) {
    let nextStatus = LocationAuthorizationStatus(status)
    authorizationStatus = nextStatus
    onAuthorizationChange?(nextStatus)
  }
}

extension LocationPermissionService: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    updateAuthorizationStatus(manager.authorizationStatus)
  }
}

final class MockLocationPermissionService: LocationPermissionServicing {
  private(set) var authorizationStatus: LocationAuthorizationStatus
  var onAuthorizationChange: ((LocationAuthorizationStatus) -> Void)?

  init(initialStatus: LocationAuthorizationStatus = .notDetermined) {
    authorizationStatus = initialStatus
  }

  func refreshAuthorizationStatus() {
    onAuthorizationChange?(authorizationStatus)
  }

  func requestWhenInUseAuthorization() {
    authorizationStatus = .whenInUse
    onAuthorizationChange?(authorizationStatus)
  }

  func requestAlwaysAuthorization() {
    authorizationStatus = .always
    onAuthorizationChange?(authorizationStatus)
  }
}
