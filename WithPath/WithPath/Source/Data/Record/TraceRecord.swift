//
//  TraceRecord.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

struct TraceRecord: Identifiable, Equatable, Sendable {
  let id: UUID
  var point: LocationPoint
  var isLowConfidence: Bool

  init(id: UUID = UUID(), point: LocationPoint, isLowConfidence: Bool = false) {
    self.id = id
    self.point = point
    self.isLowConfidence = isLowConfidence
  }
}
