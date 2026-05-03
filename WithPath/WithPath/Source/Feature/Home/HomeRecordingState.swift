//
//  HomeRecordingState.swift
//  WithPath
//
//  Created by calmkeen on 5/1/26.
//

import Foundation

enum HomeRecordingState: Equatable {
  case idle
  case requestingForegroundPermission
  case requestingBackgroundPermission
  case foregroundReady
  case backgroundReady
  case recording(LocationRecordingMode)
  case stopped
  case blocked
}
