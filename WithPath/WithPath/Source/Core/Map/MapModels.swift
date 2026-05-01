//
//  MapModels.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

struct MapMarker: Identifiable, Equatable, Sendable {
  let id: UUID
  var title: String
  var point: LocationPoint

  init(id: UUID = UUID(), title: String, point: LocationPoint) {
    self.id = id
    self.title = title
    self.point = point
  }
}

struct MapRoute: Identifiable, Equatable, Sendable {
  let id: UUID
  var points: [LocationPoint]

  init(id: UUID = UUID(), points: [LocationPoint]) {
    self.id = id
    self.points = points
  }
}
