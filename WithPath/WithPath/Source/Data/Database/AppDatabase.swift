//
//  AppDatabase.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation
import GRDB

final class AppDatabase {
  static let localUserID = "local-user"
  static let localSettingsID = "local-settings"

  let configuration: AppConfiguration
  let writer: DatabaseQueue

  private let migrator = DatabaseMigrator()

  private init(configuration: AppConfiguration, writer: DatabaseQueue) throws {
    self.configuration = configuration
    self.writer = writer

    try migrator.migrate(writer)
    try bootstrapLocalUser()
  }

  static func live(configuration: AppConfiguration) throws -> AppDatabase {
    let databaseURL = try makeDatabaseURL()
    let writer = try DatabaseQueue(path: databaseURL.path())
    return try AppDatabase(configuration: configuration, writer: writer)
  }

  static func inMemory(configuration: AppConfiguration) throws -> AppDatabase {
    let writer = try DatabaseQueue(path: ":memory:")
    return try AppDatabase(configuration: configuration, writer: writer)
  }

  private static func makeDatabaseURL() throws -> URL {
    let directoryURL = URL.documentsDirectory.appending(path: "Database", directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    return directoryURL.appending(path: "WithPath.sqlite")
  }

  private func bootstrapLocalUser() throws {
    let now = Date.now.ISO8601Format()

    try writer.write { db in
      try db.execute(
        sql: """
        INSERT OR IGNORE INTO users (
          id, email, display_name, provider, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?)
        """,
        arguments: [
          AppDatabase.localUserID,
          nil,
          "Local User",
          "local",
          now,
          now
        ]
      )

      try db.execute(
        sql: """
        INSERT OR IGNORE INTO user_settings (
          id, user_id, gps_mode, privacy_level, auto_gps_off_at_home, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        arguments: [
          AppDatabase.localSettingsID,
          AppDatabase.localUserID,
          "balanced",
          "private",
          true,
          now,
          now
        ]
      )
    }
  }
}
