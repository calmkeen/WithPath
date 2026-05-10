//
//  VisitRepository.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

protocol VisitRepository {
  func save(_ visits: [DetectedVisit]) async throws
  func visits(on date: Date) async throws -> [Visit]
}

extension VisitRepository {
  func save(_ visit: DetectedVisit) async throws {
    try await save([visit])
  }
}
