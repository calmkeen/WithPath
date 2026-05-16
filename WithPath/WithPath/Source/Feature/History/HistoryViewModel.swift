//
//  HistoryViewModel.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Combine
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
  @Published private(set) var visits: [Visit] = []
  @Published private(set) var isLoading = false
  @Published private(set) var hasLoadedTimeline = false
  @Published private(set) var errorMessage: String?

  private let buildTodayTimelineUseCase: BuildTodayTimelineUseCase

  init(visitRepository: any VisitRepository) {
    buildTodayTimelineUseCase = BuildTodayTimelineUseCase(visitRepository: visitRepository)
  }

  var hasVisits: Bool {
    !visits.isEmpty
  }

  var dateTitle: String {
    Date.now.formatted(.dateTime.month(.wide).day().weekday(.wide))
  }

  var visitCountText: String {
    "\(visits.count)곳"
  }

  var totalDurationText: String {
    let totalMinutes = visits.reduce(0) { partialResult, visit in
      partialResult + durationMinutes(for: visit)
    }

    guard totalMinutes >= 60 else {
      return "\(totalMinutes)분"
    }

    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    if minutes == 0 {
      return "\(hours)시간"
    }

    return "\(hours)시간 \(minutes)분"
  }

  func loadIfNeeded() async {
    guard !hasLoadedTimeline else { return }
    await reload()
  }

  func reload() async {
    guard !isLoading else { return }

    isLoading = true
    errorMessage = nil

    do {
      visits = try await buildTodayTimelineUseCase.execute()
      hasLoadedTimeline = true
    } catch {
      visits = []
      errorMessage = error.localizedDescription
      hasLoadedTimeline = false
    }

    isLoading = false
  }

  func timeRangeText(for visit: Visit) -> String {
    let startText = visit.startedAt.formatted(date: .omitted, time: .shortened)

    guard let endedAt = visit.endedAt else {
      return "\(startText) - 진행 중"
    }

    return "\(startText) - \(endedAt.formatted(date: .omitted, time: .shortened))"
  }

  func durationText(for visit: Visit) -> String {
    let minutes = durationMinutes(for: visit)
    guard minutes >= 60 else {
      return "\(minutes)분"
    }

    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    if remainingMinutes == 0 {
      return "\(hours)시간"
    }

    return "\(hours)시간 \(remainingMinutes)분"
  }

  func confidenceText(for visit: Visit) -> String {
    let percentage = Int((visit.confidence * 100).rounded())
    return "신뢰도 \(percentage)%"
  }

  private func durationMinutes(for visit: Visit) -> Int {
    if let durationMinutes = visit.durationMinutes {
      return max(durationMinutes, 0)
    }

    guard let endedAt = visit.endedAt else { return 0 }
    return max(Int(endedAt.timeIntervalSince(visit.startedAt) / 60), 0)
  }
}
