//
//  LocationRecordingMode.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

enum LocationRecordingMode: String, CaseIterable, Identifiable, Sendable {
  case off
  case balanced
  case precise
  case stationary
  case shareLive

  var id: String {
    rawValue
  }
}
