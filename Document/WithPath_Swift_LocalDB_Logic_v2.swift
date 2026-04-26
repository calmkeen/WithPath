// WithPath Local DB Logic Skeleton v1
// Target: iOS 16.6+, Swift 5.9/6 compatible style
// DB layer can be implemented with GRDB, SQLite.swift, CoreData, or SwiftData.

import Foundation
import CoreLocation

enum GPSMode: String, Codable {
  case off
  case balanced
  case precise
  case shareLive
}

enum ShareScope: String, Codable {
  case precise
  case blurred
  case placeOnly
  case hiddenPrivateZones
}

struct LocationPoint: Codable, Equatable {
  let latitude: Double
  let longitude: Double
  let accuracy: Double
  let speed: Double?
  let capturedAt: Date
}

struct VisitCandidate {
  var center: LocationPoint
  var points: [LocationPoint]
  var startedAt: Date

  var duration: TimeInterval {
    guard let last = points.last else { return 0 }
    return last.capturedAt.timeIntervalSince(startedAt)
  }
}

/// 역할
/// - CoreLocation에서 들어온 위치를 trace로 저장
/// - 일정 반경 안에 일정 시간 머무르면 visit로 승격
/// - 집/회사 같은 privacy zone에서는 공유용 좌표를 흐림 처리
final class LocationRecordingService {
  private let dwellRadiusMeters: Double = 80
  private let dwellThresholdSeconds: TimeInterval = 5 * 60
  private var candidate: VisitCandidate?

  func handleLocationUpdate(_ point: LocationPoint) async throws {
    guard point.accuracy <= 100 else {
      // 정확도가 낮으면 저장은 하되 방문지 판단에는 사용하지 않는 식으로 처리 가능
      try await saveTrace(point, lowConfidence: true)
      return
    }

    try await saveTrace(point, lowConfidence: false)

    if var current = candidate {
      let distance = distanceMeters(from: current.center, to: point)
      if distance <= dwellRadiusMeters {
        current.points.append(point)
        candidate = current
        if current.duration >= dwellThresholdSeconds {
          try await promoteToVisitIfNeeded(current)
        }
      } else {
        try await closeVisitIfNeeded(leavingAt: point.capturedAt)
        candidate = VisitCandidate(center: point, points: [point], startedAt: point.capturedAt)
      }
    } else {
      candidate = VisitCandidate(center: point, points: [point], startedAt: point.capturedAt)
    }
  }

  func transformedPointForSharing(_ point: LocationPoint, scope: ShareScope) async throws -> LocationPoint? {
    switch scope {
    case .precise:
      return point
    case .blurred:
      return blur(point, radiusMeters: 200)
    case .placeOnly:
      // 좌표 대신 장소명/대략적 행정구역만 서버로 보내는 정책
      return nil
    case .hiddenPrivateZones:
      let isPrivateZone = try await containsPrivateZone(point)
      return isPrivateZone ? nil : point
    }
  }

  private func saveTrace(_ point: LocationPoint, lowConfidence: Bool) async throws {
    // INSERT traces
    // INSERT sync_queue(entity: "traces", op: "insert")
  }

  private func promoteToVisitIfNeeded(_ candidate: VisitCandidate) async throws {
    // 1. geohash/반경 기준으로 locations 매칭
    // 2. 없으면 locations 생성
    // 3. visits upsert
    // 4. sync_queue 적재
  }

  private func closeVisitIfNeeded(leavingAt: Date) async throws {
    // 현재 open visit의 end_time/duration_min 업데이트
    // 집 도착 + auto_gps_off_at_home이면 GPSMode.balanced/off로 낮춤
  }

  private func containsPrivateZone(_ point: LocationPoint) async throws -> Bool {
    // home/work/private location 반경 내인지 조회
    false
  }

  private func distanceMeters(from a: LocationPoint, to b: LocationPoint) -> Double {
    let la = CLLocation(latitude: a.latitude, longitude: a.longitude)
    let lb = CLLocation(latitude: b.latitude, longitude: b.longitude)
    return la.distance(from: lb)
  }

  private func blur(_ point: LocationPoint, radiusMeters: Double) -> LocationPoint {
    // 실제 서비스에서는 안정적인 grid/geohash 기반 흐림 처리를 권장
    let latOffset = radiusMeters / 111_000
    let lngOffset = radiusMeters / (111_000 * cos(point.latitude * .pi / 180))
    let roundedLat = (point.latitude / latOffset).rounded() * latOffset
    let roundedLng = (point.longitude / lngOffset).rounded() * lngOffset
    return LocationPoint(latitude: roundedLat, longitude: roundedLng, accuracy: max(point.accuracy, radiusMeters), speed: nil, capturedAt: point.capturedAt)
  }
}

final class ShareService {
  func startShare(targetUserIDs: [String], scope: ShareScope, until endTime: Date?) async throws {
    // 1. shares row 생성(status: pending)
    // 2. share_participants 생성(status: pending)
    // 3. 상대방 수락 후 status active
    // 4. active 중에만 live location 업로드
  }

  func stopShare(shareID: String) async throws {
    // shares.status = ended/revoked
    // 서버 동기화 + 로컬 UI 즉시 반영
  }
}
