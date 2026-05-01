//
//  AppConfiguration.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

struct AppConfiguration: Equatable, Sendable {
  let usesMockLocation: Bool
  let rawTraceRetentionDays: Int
  let defaultRecordingMode: LocationRecordingMode

  static let live = AppConfiguration(
    usesMockLocation: false,
    rawTraceRetentionDays: 30,
    defaultRecordingMode: .balanced
  )

  static let debugMock = AppConfiguration(
    usesMockLocation: true,
    rawTraceRetentionDays: 30,
    defaultRecordingMode: .balanced
  )
}
