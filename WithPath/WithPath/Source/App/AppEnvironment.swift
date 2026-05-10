//
//  AppEnvironment.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation

struct AppEnvironment {
  let configuration: AppConfiguration
  let database: AppDatabase
  let traceRepository: any TraceRepository
  let locationProvider: any LocationProviding
  let locationPermissionService: any LocationPermissionServicing
  let locationRecordingService: any LocationRecordingServicing

  static func live() -> AppEnvironment {
#if DEBUG
    if !UserDefaults.standard.bool(forKey: "WithPath.useRealLocation") {
      let database = makeDatabase(configuration: .debugMock)
      let traceRepository = GRDBTraceRepository(database: database)
      let provider = MockLocationProvider()
      return AppEnvironment(
        configuration: .debugMock,
        database: database,
        traceRepository: traceRepository,
        locationProvider: provider,
        locationPermissionService: MockLocationPermissionService(),
        locationRecordingService: LocationRecordingService(
          provider: provider,
          traceRepository: traceRepository
        )
      )
    }
#endif

    let database = makeDatabase(configuration: .live)
    let traceRepository = GRDBTraceRepository(database: database)
    let provider = CoreLocationProvider()
    return AppEnvironment(
      configuration: .live,
      database: database,
      traceRepository: traceRepository,
      locationProvider: provider,
      locationPermissionService: LocationPermissionService(),
      locationRecordingService: LocationRecordingService(
        provider: provider,
        traceRepository: traceRepository
      )
    )
  }

  static func preview() -> AppEnvironment {
    let database = makePreviewDatabase()
    let traceRepository = GRDBTraceRepository(database: database)
    let provider = StaticLocationProvider()
    return AppEnvironment(
      configuration: .debugMock,
      database: database,
      traceRepository: traceRepository,
      locationProvider: provider,
      locationPermissionService: MockLocationPermissionService(),
      locationRecordingService: MockLocationRecordingService()
    )
  }

  private static func makeDatabase(configuration: AppConfiguration) -> AppDatabase {
    do {
      return try AppDatabase.live(configuration: configuration)
    } catch {
      fatalError("Failed to prepare local database: \(error.localizedDescription)")
    }
  }

  private static func makePreviewDatabase() -> AppDatabase {
    do {
      return try AppDatabase.inMemory(configuration: .debugMock)
    } catch {
      fatalError("Failed to prepare preview database: \(error.localizedDescription)")
    }
  }
}
