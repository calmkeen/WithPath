//
//  MapFeatureViewModel.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Combine
import CoreLocation
import Foundation
import MapKit
import SwiftUI

@MainActor
final class MapFeatureViewModel: ObservableObject {
  @Published private(set) var route: MapRoute?
  @Published private(set) var isLoading = false
  @Published private(set) var hasLoadedRoute = false
  @Published private(set) var errorMessage: String?
  @Published var cameraPosition: MapCameraPosition = .region(.withPathDefault)

  private let traceRepository: any TraceRepository
  private let maxTraceCount = 300

  init(traceRepository: any TraceRepository) {
    self.traceRepository = traceRepository
  }

  var routeCoordinates: [CLLocationCoordinate2D] {
    route?.points.map(\.coordinate) ?? []
  }

  var startCoordinate: CLLocationCoordinate2D? {
    routeCoordinates.first
  }

  var endCoordinate: CLLocationCoordinate2D? {
    guard routeCoordinates.count > 1 else { return nil }
    return routeCoordinates.last
  }

  var pointCountText: String {
    "\(route?.points.count ?? 0)개 포인트"
  }

  var distanceText: String {
    guard let route, route.points.count > 1 else {
      return "0 m"
    }

    let distance = distanceMeters(in: route.points)
    if distance >= 1000 {
      return String(format: "%.1f km", distance / 1000)
    }

    return "\(Int(distance.rounded())) m"
  }

  var statusTitle: String {
    if isLoading {
      return "경로 불러오는 중"
    }

    if errorMessage != nil {
      return "경로를 불러오지 못했어요"
    }

    guard let route, !route.points.isEmpty else {
      return "저장된 경로 없음"
    }

    return "최근 경로"
  }

  var statusSubtitle: String {
    if let errorMessage {
      return errorMessage
    }

    guard let route, !route.points.isEmpty else {
      return "0개 포인트"
    }

    return "\(pointCountText) · \(distanceText)"
  }

  func loadIfNeeded() async {
    guard !hasLoadedRoute else { return }
    await reload()
  }

  func reload() async {
    guard !isLoading else { return }

    isLoading = true
    errorMessage = nil

    do {
      let traces = try await traceRepository.recentTraces(limit: maxTraceCount)
      let points = traces.map(\.point)
      route = MapRoute(points: points)
      cameraPosition = .region(Self.region(for: points))
      hasLoadedRoute = true
    } catch {
      errorMessage = error.localizedDescription
      route = nil
      cameraPosition = .region(.withPathDefault)
      hasLoadedRoute = false
    }

    isLoading = false
  }

  private func distanceMeters(in points: [LocationPoint]) -> CLLocationDistance {
    zip(points, points.dropFirst()).reduce(0) { totalDistance, pair in
      let previous = CLLocation(latitude: pair.0.latitude, longitude: pair.0.longitude)
      let current = CLLocation(latitude: pair.1.latitude, longitude: pair.1.longitude)
      return totalDistance + current.distance(from: previous)
    }
  }

  private static func region(for points: [LocationPoint]) -> MKCoordinateRegion {
    guard let firstPoint = points.first else {
      return .withPathDefault
    }

    guard points.count > 1 else {
      return MKCoordinateRegion(
        center: firstPoint.coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
      )
    }

    let latitudes = points.map(\.latitude)
    let longitudes = points.map(\.longitude)

    let minLatitude = latitudes.min() ?? firstPoint.latitude
    let maxLatitude = latitudes.max() ?? firstPoint.latitude
    let minLongitude = longitudes.min() ?? firstPoint.longitude
    let maxLongitude = longitudes.max() ?? firstPoint.longitude

    let center = CLLocationCoordinate2D(
      latitude: (minLatitude + maxLatitude) / 2,
      longitude: (minLongitude + maxLongitude) / 2
    )
    let latitudeDelta = max((maxLatitude - minLatitude) * 1.7, 0.006)
    let longitudeDelta = max((maxLongitude - minLongitude) * 1.7, 0.006)

    return MKCoordinateRegion(
      center: center,
      span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    )
  }
}

private extension MKCoordinateRegion {
  static let withPathDefault = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
  )
}
