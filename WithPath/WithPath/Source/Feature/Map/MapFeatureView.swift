//
//  MapFeatureView.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import MapKit
import SwiftUI

struct MapFeatureView: View {
  @StateObject private var viewModel: MapFeatureViewModel

  init(traceRepository: any TraceRepository) {
    _viewModel = StateObject(
      wrappedValue: MapFeatureViewModel(traceRepository: traceRepository)
    )
  }

  var body: some View {
    NavigationStack {
      ZStack(alignment: .bottom) {
        routeMap

        routeStatusPanel
          .padding(.horizontal, WPSpacing.md)
          .padding(.bottom, WPSpacing.md)
      }
      .background(WPColor.background)
      .navigationTitle("지도")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            Task {
              await viewModel.reload()
            }
          } label: {
            Image(systemName: "arrow.clockwise")
          }
          .accessibilityLabel("경로 새로고침")
        }
      }
      .task {
        await viewModel.reload()
      }
    }
  }

  private var routeMap: some View {
    Map(position: $viewModel.cameraPosition, interactionModes: .all) {
      if viewModel.routeCoordinates.count > 1 {
        MapPolyline(coordinates: viewModel.routeCoordinates)
          .stroke(WPColor.primary, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
      }

      if let startCoordinate = viewModel.startCoordinate {
        Annotation("출발", coordinate: startCoordinate) {
          routeEndpoint(color: WPColor.routeStart, systemImage: "play.fill")
        }
      }

      if let endCoordinate = viewModel.endCoordinate {
        Annotation("도착", coordinate: endCoordinate) {
          routeEndpoint(color: WPColor.routeEnd, systemImage: "flag.fill")
        }
      }
    }
    .mapStyle(.standard(elevation: .realistic))
    .mapControls {
      MapCompass()
      MapScaleView()
    }
    .ignoresSafeArea(edges: .bottom)
  }

  private var routeStatusPanel: some View {
    HStack(spacing: WPSpacing.md) {
      if viewModel.isLoading {
        ProgressView()
          .tint(WPColor.primary)
      } else {
        Image(systemName: panelSystemImage)
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(panelIconColor)
          .frame(width: 28, height: 28)
      }

      VStack(alignment: .leading, spacing: WPSpacing.xs) {
        Text(viewModel.statusTitle)
          .font(.wp(.headline))
          .foregroundStyle(WPColor.ink)

        Text(viewModel.statusSubtitle)
          .font(.wp(.subheadline))
          .foregroundStyle(WPColor.muted)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: WPSpacing.sm)
    }
    .padding(WPSpacing.md)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.regularMaterial)
    .clipShape(.rect(cornerRadius: WPRadius.card))
    .overlay {
      RoundedRectangle(cornerRadius: WPRadius.card)
        .stroke(WPColor.line)
    }
  }

  private var panelSystemImage: String {
    if viewModel.errorMessage != nil {
      return "exclamationmark.triangle.fill"
    }

    if viewModel.routeCoordinates.isEmpty {
      return "map"
    }

    return "point.topleft.down.curvedto.point.bottomright.up.fill"
  }

  private var panelIconColor: Color {
    if viewModel.errorMessage != nil {
      return WPColor.warning
    }

    if viewModel.routeCoordinates.isEmpty {
      return WPColor.muted
    }

    return WPColor.primary
  }

  private func routeEndpoint(color: Color, systemImage: String) -> some View {
    Image(systemName: systemImage)
      .font(.system(size: 11, weight: .bold))
      .foregroundStyle(.white)
      .frame(width: 28, height: 28)
      .background(color)
      .clipShape(Circle())
      .shadow(color: .black.opacity(0.16), radius: 6, y: 3)
  }
}

#Preview {
  MapFeatureView(traceRepository: PreviewTraceRepository())
}

private struct PreviewTraceRepository: TraceRepository {
  func save(_ trace: TraceRecord) async throws {}

  func recentTraces(limit: Int) async throws -> [TraceRecord] {
    [
      TraceRecord(
        point: LocationPoint(latitude: 37.5665, longitude: 126.9780, horizontalAccuracy: 18, speed: 1.1)
      ),
      TraceRecord(
        point: LocationPoint(latitude: 37.5672, longitude: 126.9796, horizontalAccuracy: 17, speed: 1.2)
      ),
      TraceRecord(
        point: LocationPoint(latitude: 37.5681, longitude: 126.9810, horizontalAccuracy: 20, speed: 0.9)
      ),
      TraceRecord(
        point: LocationPoint(latitude: 37.5690, longitude: 126.9825, horizontalAccuracy: 22, speed: 1.0)
      )
    ]
  }
}
