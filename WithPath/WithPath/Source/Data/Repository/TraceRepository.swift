//
//  TraceRepository.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

protocol TraceRepository {
  func save(_ trace: TraceRecord) async throws
}
