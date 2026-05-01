//
//  PrivacyZone.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

struct PrivacyZone: Identifiable, Equatable, Sendable {
  let id: UUID
  var name: String
  var center: LocationPoint
  var radiusMeters: Double

  init(id: UUID = UUID(), name: String, center: LocationPoint, radiusMeters: Double = 200) {
    self.id = id
    self.name = name
    self.center = center
    self.radiusMeters = radiusMeters
  }
}
