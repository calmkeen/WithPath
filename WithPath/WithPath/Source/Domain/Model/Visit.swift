//
//  Visit.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

struct Visit: Identifiable, Equatable, Sendable {
  let id: UUID
  var placeName: String
  var centerPoint: LocationPoint?
  var startedAt: Date
  var endedAt: Date?
  var durationMinutes: Int?
  var confidence: Double
  var note: String?

  init(
    id: UUID = UUID(),
    placeName: String,
    centerPoint: LocationPoint? = nil,
    startedAt: Date,
    endedAt: Date? = nil,
    durationMinutes: Int? = nil,
    confidence: Double = 0,
    note: String? = nil
  ) {
    self.id = id
    self.placeName = placeName
    self.centerPoint = centerPoint
    self.startedAt = startedAt
    self.endedAt = endedAt
    self.durationMinutes = durationMinutes
    self.confidence = confidence
    self.note = note
  }
}
