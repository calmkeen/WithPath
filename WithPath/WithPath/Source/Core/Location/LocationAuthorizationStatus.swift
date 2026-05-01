//
//  LocationAuthorizationStatus.swift
//  WithPath
//
//  Created by calmkeen on 5/1/26.
//

import CoreLocation
import Foundation

enum LocationAuthorizationStatus: Equatable, Sendable {
  case notDetermined
  case restricted
  case denied
  case whenInUse
  case always
  case unknown

  init(_ status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      self = .notDetermined
    case .restricted:
      self = .restricted
    case .denied:
      self = .denied
    case .authorizedWhenInUse:
      self = .whenInUse
    case .authorizedAlways:
      self = .always
    @unknown default:
      self = .unknown
    }
  }

  var canRecordInForeground: Bool {
    switch self {
    case .whenInUse, .always:
      return true
    case .notDetermined, .restricted, .denied, .unknown:
      return false
    }
  }

  var canRecordInBackground: Bool {
    self == .always
  }

  var needsSettings: Bool {
    switch self {
    case .restricted, .denied:
      return true
    case .notDetermined, .whenInUse, .always, .unknown:
      return false
    }
  }
}
