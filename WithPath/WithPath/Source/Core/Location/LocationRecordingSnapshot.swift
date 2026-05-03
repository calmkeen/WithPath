//
//  LocationRecordingSnapshot.swift
//  WithPath
//
//  Created by calmkeen on 5/3/26.
//

import Foundation

struct LocationRecordingSnapshot: Equatable, Sendable {
  var mode: LocationRecordingMode
  var isRecording: Bool
  var startedAt: Date?
  var stoppedAt: Date?
  var lastPoint: LocationPoint?
  var receivedPointCount: Int

  static let idle = LocationRecordingSnapshot(
    mode: .off,
    isRecording: false,
    startedAt: nil,
    stoppedAt: nil,
    lastPoint: nil,
    receivedPointCount: 0
  )
}
