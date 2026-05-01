//
//  VisitRepository.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

protocol VisitRepository {
  func visits(on date: Date) async throws -> [Visit]
}
