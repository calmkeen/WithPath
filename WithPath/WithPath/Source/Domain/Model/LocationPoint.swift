//
//  LocationPoint.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import CoreLocation
import Foundation

struct LocationPoint: Identifiable, Equatable, Sendable {
  let id: UUID
  var latitude: Double
  var longitude: Double
  var horizontalAccuracy: Double
  var speed: Double?
  var capturedAt: Date

  init(
    id: UUID = UUID(),
    latitude: Double,
    longitude: Double,
    horizontalAccuracy: Double,
    speed: Double?,
    capturedAt: Date = .now
  ) {
    self.id = id
    self.latitude = latitude
    self.longitude = longitude
    self.horizontalAccuracy = horizontalAccuracy
    self.speed = speed
    self.capturedAt = capturedAt
  }

  init(location: CLLocation) {
    self.init(
      latitude: location.coordinate.latitude,
      longitude: location.coordinate.longitude,
      horizontalAccuracy: location.horizontalAccuracy,
      speed: location.speed >= 0 ? location.speed : nil,
      capturedAt: location.timestamp
    )
  }

  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}
