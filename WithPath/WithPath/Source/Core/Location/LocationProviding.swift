//
//  LocationProviding.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

protocol LocationProviding {
  func locationUpdates(configuration: LocationRecordingConfiguration) -> AsyncStream<LocationPoint>
}
