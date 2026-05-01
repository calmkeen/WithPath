//
//  LocationMaskingService.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

struct LocationMaskingService {
  func maskedPoint(_ point: LocationPoint, radiusMeters: Double = 200) -> LocationPoint {
    let latOffset = radiusMeters / 111_000
    let lngOffset = radiusMeters / (111_000 * cos(point.latitude * .pi / 180))
    let roundedLat = (point.latitude / latOffset).rounded() * latOffset
    let roundedLng = (point.longitude / lngOffset).rounded() * lngOffset

    return LocationPoint(
      latitude: roundedLat,
      longitude: roundedLng,
      horizontalAccuracy: max(point.horizontalAccuracy, radiusMeters),
      speed: nil,
      capturedAt: point.capturedAt
    )
  }
}
