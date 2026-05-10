//
//  GRDBTraceRepository.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation
import GRDB
import os

final class GRDBTraceRepository: TraceRepository {
  private let database: AppDatabase
  private let userID: String
  private let logger = Logger(subsystem: "com.calmkeen.WithPath", category: "database")

  init(database: AppDatabase, userID: String = AppDatabase.localUserID) {
    self.database = database
    self.userID = userID
  }

  func save(_ trace: TraceRecord) async throws {
    let now = Date.now.ISO8601Format()
    let capturedAt = trace.point.capturedAt.ISO8601Format()

    try await database.writer.write { db in
      try db.execute(
        sql: """
        INSERT OR REPLACE INTO traces (
          id, user_id, lat, lng, accuracy_m, speed_mps, captured_at,
          is_low_confidence, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        arguments: [
          trace.id.uuidString,
          userID,
          trace.point.latitude,
          trace.point.longitude,
          trace.point.horizontalAccuracy,
          trace.point.speed,
          capturedAt,
          trace.isLowConfidence,
          now
        ]
      )

#if DEBUG
      if let row = try Row.fetchOne(
        db,
        sql: """
        SELECT id, lat, lng, accuracy_m, speed_mps, captured_at, is_low_confidence
        FROM traces
        WHERE id = ?
        """,
        arguments: [trace.id.uuidString]
      ) {
        let id: String = row["id"]
        let lat: Double = row["lat"]
        let lng: Double = row["lng"]
        let accuracyM: Double? = row["accuracy_m"]
        let speedMps: Double? = row["speed_mps"]
        let capturedAt: String = row["captured_at"]
        let isLowConfidence: Bool = row["is_low_confidence"]
        let accuracyText = accuracyM.map { String(format: "%.1f", $0) } ?? "nil"
        let speedText = speedMps.map { String(format: "%.2f", $0) } ?? "nil"
        let message = """
        Saved trace id=\(id) lat=\(lat) lng=\(lng) accuracyM=\(accuracyText) speedMps=\(speedText) capturedAt=\(capturedAt) lowConfidence=\(isLowConfidence)
        """

        logger.debug("\(message, privacy: .public)")
        print("[WithPath][DB] \(message)")
      }
#endif
    }
  }

  func recentTraces(limit: Int = 200) async throws -> [TraceRecord] {
    let rows: [(
      id: String,
      lat: Double,
      lng: Double,
      accuracyM: Double?,
      speedMps: Double?,
      capturedAt: String,
      isLowConfidence: Bool
    )] = try await database.writer.read { db in
      try Row.fetchAll(
        db,
        sql: """
        SELECT id, lat, lng, accuracy_m, speed_mps, captured_at, is_low_confidence
        FROM traces
        WHERE user_id = ?
        ORDER BY captured_at DESC
        LIMIT ?
        """,
        arguments: [userID, limit]
      ).map { row in
        (
          id: row["id"],
          lat: row["lat"],
          lng: row["lng"],
          accuracyM: row["accuracy_m"],
          speedMps: row["speed_mps"],
          capturedAt: row["captured_at"],
          isLowConfidence: row["is_low_confidence"]
        )
      }
    }

    return rows.reversed().compactMap { row in
      guard
        let id = UUID(uuidString: row.id),
        let accuracyM = row.accuracyM,
        let capturedAtDate = try? Date(row.capturedAt, strategy: .iso8601)
      else {
        return nil
      }

      let point = LocationPoint(
        id: id,
        latitude: row.lat,
        longitude: row.lng,
        horizontalAccuracy: accuracyM,
        speed: row.speedMps,
        capturedAt: capturedAtDate
      )

      return TraceRecord(id: id, point: point, isLowConfidence: row.isLowConfidence)
    }
  }
}
