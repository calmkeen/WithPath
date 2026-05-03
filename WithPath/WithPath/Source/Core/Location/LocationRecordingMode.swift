//
//  LocationRecordingMode.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

enum LocationRecordingMode: String, CaseIterable, Identifiable, Sendable {
  case off
  case balanced
  case precise
  case stationary
  case shareLive

  var id: String {
    rawValue
  }

  var title: String {
    switch self {
    case .off:
      return "기록 꺼짐"
    case .balanced:
      return "균형 기록"
    case .precise:
      return "정밀 기록"
    case .stationary:
      return "체류 기록"
    case .shareLive:
      return "실시간 공유"
    }
  }

  var description: String {
    switch self {
    case .off:
      return "위치 업데이트를 받지 않습니다."
    case .balanced:
      return "일상 동선과 방문 장소를 배터리 친화적으로 기록합니다."
    case .precise:
      return "이동 중 경로를 더 촘촘하게 기록합니다."
    case .stationary:
      return "한 장소에 머무르는 동안 업데이트 부담을 낮춥니다."
    case .shareLive:
      return "명시적으로 공유 중일 때 더 선명한 위치를 사용합니다."
    }
  }

  var systemImage: String {
    switch self {
    case .off:
      return "pause.circle"
    case .balanced:
      return "gauge.with.dots.needle.33percent"
    case .precise:
      return "location.north.circle"
    case .stationary:
      return "mappin.circle"
    case .shareLive:
      return "dot.radiowaves.left.and.right"
    }
  }
}
