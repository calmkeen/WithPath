//
//  GRDBVisitRepository.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation
import GRDB
import os

final class GRDBVisitRepository: VisitRepository {
  private let database: AppDatabase
  private let userID: String
  private let logger = Logger(subsystem: "com.calmkeen.WithPath", category: "database")

  init(database: AppDatabase, userID: String = AppDatabase.localUserID) {
    self.database = database
    self.userID = userID
  }

  func save(_ visits: [DetectedVisit]) async throws {
    guard !visits.isEmpty else { return }

    let now = Date.now.ISO8601Format()

    try await database.writer.write { db in
      for visit in visits {
        let locationID = UUID().uuidString
        let locationName = Self.locationName(for: visit.centerPoint)
        let startedAt = visit.startedAt.ISO8601Format()
        let endedAt = visit.endedAt.ISO8601Format()
        let durationMinutes = Int((visit.durationSeconds / 60).rounded())

        try db.execute(
          sql: """
          INSERT INTO locations (
            id, lat, lng, geohash, name, address, type, is_private_zone,
            privacy_radius_m, created_at, updated_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET
            lat = excluded.lat,
            lng = excluded.lng,
            name = excluded.name,
            type = excluded.type,
            updated_at = excluded.updated_at
          """,
          arguments: [
            locationID,
            visit.centerPoint.latitude,
            visit.centerPoint.longitude,
            nil,
            locationName,
            nil,
            "detected",
            false,
            200,
            now,
            now
          ]
        )

        try db.execute(
          sql: """
          INSERT INTO visits (
            id, user_id, location_id, start_time, end_time, duration_min,
            activity_type, note, confidence, is_hidden, created_at, updated_at, deleted_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET
            location_id = excluded.location_id,
            start_time = excluded.start_time,
            end_time = excluded.end_time,
            duration_min = excluded.duration_min,
            activity_type = excluded.activity_type,
            note = excluded.note,
            confidence = excluded.confidence,
            is_hidden = excluded.is_hidden,
            updated_at = excluded.updated_at,
            deleted_at = excluded.deleted_at
          """,
          arguments: [
            visit.id.uuidString,
            userID,
            locationID,
            startedAt,
            endedAt,
            durationMinutes,
            "stationary",
            nil,
            visit.confidence,
            false,
            now,
            now,
            nil
          ]
        )

        try db.execute(
          sql: """
          UPDATE traces
          SET visit_id = ?
          WHERE user_id = ?
            AND visit_id IS NULL
            AND captured_at >= ?
            AND captured_at <= ?
          """,
          arguments: [
            visit.id.uuidString,
            userID,
            startedAt,
            endedAt
          ]
        )

#if DEBUG
        let message = """
        Saved visit id=\(visit.id.uuidString) lat=\(visit.centerPoint.latitude) lng=\(visit.centerPoint.longitude) start=\(startedAt) end=\(endedAt) durationMin=\(durationMinutes) confidence=\(String(format: "%.2f", visit.confidence))
        """
        logger.debug("\(message, privacy: .public)")
        print("[WithPath][DB] \(message)")
#endif
      }
    }
  }

  func visits(on date: Date) async throws -> [Visit] {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date

    let rows: [Row] = try database.writer.read { db in
      try Row.fetchAll(
        db,
        sql: """
        SELECT
          v.id,
          v.start_time,
          v.end_time,
          v.duration_min,
          v.note,
          v.confidence,
          l.name AS location_name,
          l.lat,
          l.lng
        FROM visits v
        LEFT JOIN locations l ON l.id = v.location_id
        WHERE v.user_id = ?
          AND v.deleted_at IS NULL
          AND v.start_time >= ?
          AND v.start_time < ?
        ORDER BY v.start_time ASC
        """,
        arguments: [
          userID,
          startOfDay.ISO8601Format(),
          endOfDay.ISO8601Format()
        ]
      )
    }

    return rows.compactMap(Self.visit(from:))
  }

  private static func visit(from row: Row) -> Visit? {
    let idString: String = row["id"]
    let startedAtString: String = row["start_time"]
    let endedAtString: String? = row["end_time"]
    let durationMinutes: Int? = row["duration_min"]
    let note: String? = row["note"]
    let confidence: Double = row["confidence"]
    let locationName: String? = row["location_name"]
    let latitude: Double? = row["lat"]
    let longitude: Double? = row["lng"]

    guard
      let id = UUID(uuidString: idString),
      let startedAt = try? Date(startedAtString, strategy: .iso8601)
    else {
      return nil
    }

    let endedAt = endedAtString.flatMap { try? Date($0, strategy: .iso8601) }
    let centerPoint = makeCenterPoint(latitude: latitude, longitude: longitude, capturedAt: startedAt)

    return Visit(
      id: id,
      placeName: locationName ?? centerPoint.map(locationName(for:)) ?? "알 수 없는 장소",
      centerPoint: centerPoint,
      startedAt: startedAt,
      endedAt: endedAt,
      durationMinutes: durationMinutes,
      confidence: confidence,
      note: note
    )
  }

  private static func makeCenterPoint(
    latitude: Double?,
    longitude: Double?,
    capturedAt: Date
  ) -> LocationPoint? {
    guard let latitude, let longitude else { return nil }

    return LocationPoint(
      latitude: latitude,
      longitude: longitude,
      horizontalAccuracy: 0,
      speed: nil,
      capturedAt: capturedAt
    )
  }

  nonisolated private static func locationName(for point: LocationPoint) -> String {
    String(format: "%.5f, %.5f", point.latitude, point.longitude)
  }
}
