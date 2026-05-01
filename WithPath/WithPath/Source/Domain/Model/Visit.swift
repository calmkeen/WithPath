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
  var startedAt: Date
  var endedAt: Date?
  var note: String?

  init(
    id: UUID = UUID(),
    placeName: String,
    startedAt: Date,
    endedAt: Date? = nil,
    note: String? = nil
  ) {
    self.id = id
    self.placeName = placeName
    self.startedAt = startedAt
    self.endedAt = endedAt
    self.note = note
  }
}
