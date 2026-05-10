//
//  DatabaseMigrator.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation
import GRDB

struct DatabaseMigrator {
  let schemaVersion: SchemaVersion = .v1

  func migrate(_ writer: DatabaseQueue) throws {
    var migrator = GRDB.DatabaseMigrator()

    migrator.registerMigration("v\(schemaVersion.rawValue)") { db in
      try db.create(table: "users", ifNotExists: true) { table in
        table.column("id", .text).primaryKey()
        table.column("email", .text)
        table.column("display_name", .text)
        table.column("provider", .text).notNull()
        table.column("created_at", .text).notNull()
        table.column("updated_at", .text).notNull()
      }

      try db.create(table: "locations", ifNotExists: true) { table in
        table.column("id", .text).primaryKey()
        table.column("lat", .double).notNull()
        table.column("lng", .double).notNull()
        table.column("geohash", .text)
        table.column("name", .text)
        table.column("address", .text)
        table.column("type", .text).notNull().defaults(to: "unknown")
        table.column("is_private_zone", .boolean).notNull().defaults(to: false)
        table.column("privacy_radius_m", .integer).notNull().defaults(to: 200)
        table.column("created_at", .text).notNull()
        table.column("updated_at", .text).notNull()
      }

      try db.create(table: "user_settings", ifNotExists: true) { table in
        table.column("id", .text).primaryKey()
        table.column("user_id", .text)
          .notNull()
          .references("users", onDelete: .cascade)
        table.column("gps_mode", .text).notNull().defaults(to: "balanced")
        table.column("privacy_level", .text).notNull().defaults(to: "private")
        table.column("home_location_id", .text)
          .references("locations", onDelete: .setNull)
        table.column("work_location_id", .text)
          .references("locations", onDelete: .setNull)
        table.column("auto_gps_off_at_home", .boolean).notNull().defaults(to: true)
        table.column("created_at", .text).notNull()
        table.column("updated_at", .text).notNull()
      }

      try db.create(table: "visits", ifNotExists: true) { table in
        table.column("id", .text).primaryKey()
        table.column("user_id", .text)
          .notNull()
          .references("users", onDelete: .cascade)
        table.column("location_id", .text)
          .references("locations", onDelete: .setNull)
        table.column("start_time", .text).notNull()
        table.column("end_time", .text)
        table.column("duration_min", .integer)
        table.column("activity_type", .text)
        table.column("note", .text)
        table.column("confidence", .double).notNull().defaults(to: 0)
        table.column("is_hidden", .boolean).notNull().defaults(to: false)
        table.column("created_at", .text).notNull()
        table.column("updated_at", .text).notNull()
        table.column("deleted_at", .text)
      }

      try db.create(table: "traces", ifNotExists: true) { table in
        table.column("id", .text).primaryKey()
        table.column("user_id", .text)
          .notNull()
          .references("users", onDelete: .cascade)
        table.column("visit_id", .text)
          .references("visits", onDelete: .cascade)
        table.column("lat", .double).notNull()
        table.column("lng", .double).notNull()
        table.column("accuracy_m", .double)
        table.column("speed_mps", .double)
        table.column("captured_at", .text).notNull()
        table.column("is_low_confidence", .boolean).notNull().defaults(to: false)
        table.column("created_at", .text).notNull()
      }

      try db.create(table: "sync_queue", ifNotExists: true) { table in
        table.column("id", .text).primaryKey()
        table.column("entity_type", .text).notNull()
        table.column("entity_id", .text).notNull()
        table.column("operation", .text).notNull()
        table.column("payload", .text)
        table.column("status", .text).notNull().defaults(to: "pending")
        table.column("retry_count", .integer).notNull().defaults(to: 0)
        table.column("created_at", .text).notNull()
        table.column("updated_at", .text).notNull()
      }

      try db.create(
        index: "idx_locations_geohash",
        on: "locations",
        columns: ["geohash"],
        ifNotExists: true
      )
      try db.create(
        index: "idx_user_settings_user_id",
        on: "user_settings",
        columns: ["user_id"],
        ifNotExists: true
      )
      try db.create(
        index: "idx_visits_user_start_time",
        on: "visits",
        columns: ["user_id", "start_time"],
        ifNotExists: true
      )
      try db.create(
        index: "idx_traces_user_captured_at",
        on: "traces",
        columns: ["user_id", "captured_at"],
        ifNotExists: true
      )
      try db.create(
        index: "idx_sync_queue_status_created_at",
        on: "sync_queue",
        columns: ["status", "created_at"],
        ifNotExists: true
      )
    }

    try migrator.migrate(writer)
  }
}
