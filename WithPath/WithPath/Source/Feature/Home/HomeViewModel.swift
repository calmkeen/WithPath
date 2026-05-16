//
//  HomeViewModel.swift
//  WithPath
//
//  Created by calmkeen on 5/1/26.
//

import Combine
import CoreLocation
import Foundation
import UIKit

@MainActor
final class HomeViewModel: ObservableObject {
  @Published private(set) var authorizationStatus: LocationAuthorizationStatus
  @Published private(set) var recordingState: HomeRecordingState = .idle
  @Published private(set) var recordingSnapshot: LocationRecordingSnapshot
  @Published private(set) var todayVisits: [Visit] = []
  @Published private(set) var todayTracePoints: [LocationPoint] = []
  @Published private(set) var isLoadingTodaySummary = false
  @Published private(set) var hasLoadedTodaySummary = false
  @Published private(set) var todaySummaryError: String?

  private let permissionService: any LocationPermissionServicing
  private let recordingService: any LocationRecordingServicing
  private let traceRepository: any TraceRepository
  private let visitRepository: any VisitRepository

  init(
    permissionService: any LocationPermissionServicing,
    recordingService: any LocationRecordingServicing,
    traceRepository: any TraceRepository,
    visitRepository: any VisitRepository
  ) {
    self.permissionService = permissionService
    self.recordingService = recordingService
    self.traceRepository = traceRepository
    self.visitRepository = visitRepository
    authorizationStatus = permissionService.authorizationStatus
    recordingSnapshot = recordingService.snapshot

    permissionService.onAuthorizationChange = { [weak self] status in
      Task { @MainActor in
        self?.handleAuthorizationChange(status)
      }
    }

    recordingService.onSnapshotChange = { [weak self] snapshot in
      Task { @MainActor in
        self?.handleRecordingSnapshotChange(snapshot)
      }
    }

    permissionService.refreshAuthorizationStatus()
  }

  var statusTitle: String {
    switch authorizationStatus {
    case .notDetermined:
      return "위치 권한이 필요해요"
    case .whenInUse:
      return "앱 사용 중 기록 가능"
    case .always:
      return "백그라운드 기록 가능"
    case .restricted:
      return "위치 접근이 제한되어 있어요"
    case .denied:
      return "위치 권한이 꺼져 있어요"
    case .unknown:
      return "권한 상태 확인 중"
    }
  }

  var statusDescription: String {
    switch authorizationStatus {
    case .notDetermined:
      return "기록 시작을 누르면 오늘 동선을 만들기 위한 위치 권한을 요청합니다."
    case .whenInUse:
      return "앱을 켜둔 동안 동선을 기록할 수 있습니다. 백그라운드 기록은 별도로 켤 수 있어요."
    case .always:
      return "앱을 닫아도 사용자가 켜둔 기록 흐름을 이어갈 수 있습니다."
    case .restricted:
      return "기기 또는 보호자 설정 때문에 WithPath가 위치에 접근할 수 없습니다."
    case .denied:
      return "설정에서 위치 권한을 허용하면 다시 기록을 시작할 수 있습니다."
    case .unknown:
      return "현재 iOS 위치 권한 상태를 다시 확인하고 있습니다."
    }
  }

  var primaryActionTitle: String {
    if recordingSnapshot.isRecording {
      return "기록 중지"
    }

    switch authorizationStatus {
    case .notDetermined:
      return "기록 시작"
    case .whenInUse, .always:
      return "오늘 기록 시작"
    case .restricted, .denied:
      return "설정 열기"
    case .unknown:
      return "권한 다시 확인"
    }
  }

  var primaryActionSystemImage: String {
    if recordingSnapshot.isRecording {
      return "stop.fill"
    }

    switch authorizationStatus {
    case .notDetermined:
      return "location.fill"
    case .whenInUse, .always:
      return "play.fill"
    case .restricted, .denied:
      return "gearshape.fill"
    case .unknown:
      return "arrow.clockwise"
    }
  }

  var recordingStateText: String {
    switch recordingState {
    case .idle:
      return "기록 꺼짐"
    case .requestingForegroundPermission:
      return "권한 요청 중"
    case .requestingBackgroundPermission:
      return "백그라운드 권한 요청 중"
    case .foregroundReady:
      return "앱 사용 중 기록 준비"
    case .backgroundReady:
      return "백그라운드 기록 준비"
    case .recording(let mode):
      return "\(mode.title) 중"
    case .stopped:
      return "기록 중지됨"
    case .blocked:
      return "권한 필요"
    }
  }

  var dateTitle: String {
    Date.now.formatted(.dateTime.month(.wide).day().weekday(.wide))
  }

  var currentStatusTitle: String {
    if recordingSnapshot.isRecording {
      return "현재 기록 중이에요"
    }

    if let latestVisit = todayVisits.last {
      return "최근 \(latestVisit.placeName)"
    }

    switch authorizationStatus {
    case .notDetermined:
      return "오늘 기록을 시작해보세요"
    case .restricted, .denied:
      return "위치 권한이 필요해요"
    case .whenInUse, .always:
      return "오늘 기록 준비됨"
    case .unknown:
      return "상태 확인 중"
    }
  }

  var currentStatusSubtitle: String {
    if recordingSnapshot.isRecording {
      return "\(currentModeTitle) · \(receivedPointText)"
    }

    if let latestVisit = todayVisits.last {
      return "\(timeText(for: latestVisit.startedAt)) 도착 · \(durationText(for: latestVisit))"
    }

    return recordingStateText
  }

  var totalDistanceText: String {
    let distance = totalDistanceMeters()
    guard distance >= 1000 else {
      return "\(Int(distance.rounded())) m"
    }

    return String(format: "%.1f km", distance / 1000)
  }

  var visitedPlaceCountText: String {
    "\(todayVisits.count)곳"
  }

  var totalDurationText: String {
    durationText(minutes: todayVisits.reduce(0) { partialResult, visit in
      partialResult + durationMinutes(for: visit)
    })
  }

  var compactTimelineVisits: [Visit] {
    Array(todayVisits.prefix(4))
  }

  var showsBackgroundAction: Bool {
    authorizationStatus == .whenInUse && !recordingSnapshot.isRecording
  }

  var currentModeTitle: String {
    recordingSnapshot.mode.title
  }

  var currentModeDescription: String {
    recordingSnapshot.mode.description
  }

  var receivedPointText: String {
    "\(recordingSnapshot.receivedPointCount)개 샘플"
  }

  var canShowRecordingSummary: Bool {
    recordingSnapshot.isRecording || recordingSnapshot.receivedPointCount > 0
  }

  func loadTodaySummaryIfNeeded() async {
    guard !hasLoadedTodaySummary else { return }
    await reloadTodaySummary()
  }

  func reloadTodaySummary() async {
    guard !isLoadingTodaySummary else { return }

    isLoadingTodaySummary = true
    todaySummaryError = nil

    do {
      async let visits = visitRepository.visits(on: .now)
      async let traces = traceRepository.traces(on: .now)
      let loadedVisits = try await visits
      let loadedTraces = try await traces
      todayVisits = loadedVisits
      todayTracePoints = loadedTraces.map(\.point)
      hasLoadedTodaySummary = true
    } catch {
      todayVisits = []
      todayTracePoints = []
      todaySummaryError = error.localizedDescription
      hasLoadedTodaySummary = false
    }

    isLoadingTodaySummary = false
  }

  func primaryActionTapped() {
    if recordingSnapshot.isRecording {
      recordingService.stop()
      return
    }

    switch authorizationStatus {
    case .notDetermined:
      recordingState = .requestingForegroundPermission
      permissionService.requestWhenInUseAuthorization()
    case .whenInUse:
      startRecording(mode: .balanced)
    case .always:
      startRecording(mode: .balanced)
    case .restricted, .denied:
      openSettings()
    case .unknown:
      permissionService.refreshAuthorizationStatus()
    }
  }

  func backgroundActionTapped() {
    guard authorizationStatus == .whenInUse else {
      primaryActionTapped()
      return
    }

    recordingState = .requestingBackgroundPermission
    permissionService.requestAlwaysAuthorization()
  }

  func preciseModeTapped() {
    guard authorizationStatus.canRecordInForeground else {
      primaryActionTapped()
      return
    }

    startRecording(mode: .precise)
  }

  func timeRangeText(for visit: Visit) -> String {
    let startText = timeText(for: visit.startedAt)
    guard let endedAt = visit.endedAt else {
      return "\(startText) - 진행 중"
    }

    return "\(startText) - \(timeText(for: endedAt))"
  }

  func durationText(for visit: Visit) -> String {
    durationText(minutes: durationMinutes(for: visit))
  }

  private func handleAuthorizationChange(_ status: LocationAuthorizationStatus) {
    authorizationStatus = status

    switch status {
    case .whenInUse:
      recordingState = .foregroundReady
    case .always:
      recordingState = .backgroundReady
    case .restricted, .denied:
      recordingState = .blocked
    case .notDetermined, .unknown:
      break
    }
  }

  private func handleRecordingSnapshotChange(_ snapshot: LocationRecordingSnapshot) {
    recordingSnapshot = snapshot

    if snapshot.isRecording {
      recordingState = .recording(snapshot.mode)
    } else if snapshot.stoppedAt != nil {
      recordingState = .stopped
      Task {
        try? await Task.sleep(for: .milliseconds(500))
        await reloadTodaySummary()
      }
    }
  }

  private func startRecording(mode: LocationRecordingMode) {
    guard authorizationStatus.canRecordInForeground else {
      recordingState = .blocked
      return
    }

    recordingService.start(mode: mode)
  }

  private func openSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }

  private func totalDistanceMeters() -> CLLocationDistance {
    zip(todayTracePoints, todayTracePoints.dropFirst()).reduce(0) { totalDistance, pair in
      let previousLocation = CLLocation(latitude: pair.0.latitude, longitude: pair.0.longitude)
      let currentLocation = CLLocation(latitude: pair.1.latitude, longitude: pair.1.longitude)
      return totalDistance + currentLocation.distance(from: previousLocation)
    }
  }

  private func durationMinutes(for visit: Visit) -> Int {
    if let durationMinutes = visit.durationMinutes {
      return max(durationMinutes, 0)
    }

    guard let endedAt = visit.endedAt else { return 0 }
    return max(Int(endedAt.timeIntervalSince(visit.startedAt) / 60), 0)
  }

  private func durationText(minutes: Int) -> String {
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

  private func timeText(for date: Date) -> String {
    date.formatted(date: .omitted, time: .shortened)
  }
}
