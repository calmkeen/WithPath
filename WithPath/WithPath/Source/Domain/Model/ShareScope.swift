//
//  ShareScope.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

enum ShareScope: String, CaseIterable, Identifiable, Sendable {
  case precise
  case blurred
  case placeOnly
  case hiddenPrivateZones

  var id: String {
    rawValue
  }
}
