//
//  HomeViewModel.swift
//  WithPath
//
//  Created by calmkeen on 5/1/26.
//

import Combine
import Foundation
import UIKit

@MainActor
final class HomeViewModel: ObservableObject {
  @Published private(set) var authorizationStatus: LocationAuthorizationStatus
  @Published private(set) var recordingState: HomeRecordingState = .idle

  private let permissionService: any LocationPermissionServicing

  init(permissionService: any LocationPermissionServicing) {
    self.permissionService = permissionService
    authorizationStatus = permissionService.authorizationStatus

    permissionService.onAuthorizationChange = { [weak self] status in
      Task { @MainActor in
        self?.handleAuthorizationChange(status)
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
    switch authorizationStatus {
    case .notDetermined:
      return "기록 시작"
    case .whenInUse, .always:
      return "오늘 기록 준비"
    case .restricted, .denied:
      return "설정 열기"
    case .unknown:
      return "권한 다시 확인"
    }
  }

  var primaryActionSystemImage: String {
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
    case .blocked:
      return "권한 필요"
    }
  }

  var showsBackgroundAction: Bool {
    authorizationStatus == .whenInUse
  }

  func primaryActionTapped() {
    switch authorizationStatus {
    case .notDetermined:
      recordingState = .requestingForegroundPermission
      permissionService.requestWhenInUseAuthorization()
    case .whenInUse:
      recordingState = .foregroundReady
    case .always:
      recordingState = .backgroundReady
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

  private func openSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }
}
