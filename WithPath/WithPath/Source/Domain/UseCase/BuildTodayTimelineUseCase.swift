//
//  BuildTodayTimelineUseCase.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

struct BuildTodayTimelineUseCase {
  let visitRepository: any VisitRepository

  func execute(now: Date = .now) async throws -> [Visit] {
    try await visitRepository.visits(on: now)
  }
}
