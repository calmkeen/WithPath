//
//  LocationProviding.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

protocol LocationProviding {
  func locationUpdates(mode: LocationRecordingMode) -> AsyncStream<LocationPoint>
}
