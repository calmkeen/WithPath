//
//  SavedPlace.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

struct SavedPlace: Identifiable, Equatable, Sendable {
  let id: UUID
  var name: String
  var point: LocationPoint
  var isPrivateZone: Bool

  init(id: UUID = UUID(), name: String, point: LocationPoint, isPrivateZone: Bool = false) {
    self.id = id
    self.name = name
    self.point = point
    self.isPrivateZone = isPrivateZone
  }
}
