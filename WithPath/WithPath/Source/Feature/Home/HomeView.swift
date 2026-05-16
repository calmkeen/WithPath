//
//  HomeView.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel: HomeViewModel

  init(
    permissionService: any LocationPermissionServicing,
    recordingService: any LocationRecordingServicing,
    traceRepository: any TraceRepository,
    visitRepository: any VisitRepository
  ) {
    _viewModel = StateObject(
      wrappedValue: HomeViewModel(
        permissionService: permissionService,
        recordingService: recordingService,
        traceRepository: traceRepository,
        visitRepository: visitRepository
      )
    )
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: WPSpacing.lg) {
          header

          statusCard

          if viewModel.showsBackgroundAction {
            backgroundCard
          }

          routeSection

          summarySection
        }
        .padding(WPSpacing.lg)
      }
      .background(WPColor.background)
      .navigationTitle("오늘")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            Task {
              await viewModel.reloadTodaySummary()
            }
          } label: {
            Image(systemName: "arrow.clockwise")
          }
          .accessibilityLabel("오늘 요약 새로고침")
        }
      }
      .task {
        await viewModel.loadTodaySummaryIfNeeded()
      }
    }
  }

  private var header: some View {
    HStack(alignment: .center, spacing: WPSpacing.md) {
      VStack(alignment: .leading, spacing: WPSpacing.xs) {
        Text(viewModel.dateTitle)
          .font(.wp(.title2))
          .foregroundStyle(WPColor.ink)

        Text(viewModel.recordingStateText)
          .font(.wp(.subheadline))
          .foregroundStyle(WPColor.muted)
      }

      Spacer()

      Image(systemName: notificationSystemImage)
        .font(.system(size: 20, weight: .semibold))
        .foregroundStyle(WPColor.primary)
        .frame(width: 40, height: 40)
        .background(WPColor.surface)
        .clipShape(Circle())
        .overlay {
          Circle().stroke(WPColor.line)
        }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var statusCard: some View {
    VStack(alignment: .leading, spacing: WPSpacing.md) {
      HStack(alignment: .center, spacing: WPSpacing.md) {
        Image(systemName: statusSystemImage)
          .font(.system(size: 24, weight: .semibold))
          .foregroundStyle(WPColor.primary)
          .frame(width: 42, height: 42)
          .background(WPColor.primarySoft)
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: WPSpacing.xs) {
          Text(viewModel.currentStatusTitle)
            .font(.wp(.title2))
            .foregroundStyle(WPColor.ink)
            .lineLimit(1)

          Text(viewModel.currentStatusSubtitle)
            .font(.wp(.subheadline))
            .foregroundStyle(WPColor.muted)
        }

        Spacer()
      }

      if viewModel.showsLiveSessionSummary {
        liveSessionSummary
      }

      HStack(spacing: WPSpacing.sm) {
        Button(action: viewModel.primaryActionTapped) {
          Label(viewModel.primaryActionTitle, systemImage: viewModel.primaryActionSystemImage)
            .font(.wp(.headline))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: WPRadius.button))
        .controlSize(.large)
        .tint(WPColor.primary)

        if !viewModel.recordingSnapshot.isRecording &&
          viewModel.authorizationStatus.canRecordInForeground {
          Button(action: viewModel.preciseModeTapped) {
            Image(systemName: LocationRecordingMode.precise.systemImage)
              .font(.system(size: 18, weight: .semibold))
              .frame(width: 44, height: 44)
          }
          .buttonStyle(.bordered)
          .buttonBorderShape(.roundedRectangle(radius: WPRadius.button))
          .tint(WPColor.secondary)
          .accessibilityLabel("정밀 기록 시작")
        }
      }
    }
    .padding(WPSpacing.lg)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(WPColor.primarySoft)
    .clipShape(.rect(cornerRadius: WPRadius.card))
  }

  private var liveSessionSummary: some View {
    VStack(alignment: .leading, spacing: WPSpacing.sm) {
      HStack(spacing: 0) {
        liveMetric(title: "세션 이동", value: viewModel.liveSessionDistanceText)
        Divider()
          .frame(height: 36)
        liveMetric(title: "샘플", value: viewModel.receivedPointText)
        Divider()
          .frame(height: 36)
        liveMetric(title: "저장", value: viewModel.lastSavedText)
      }
      .padding(.vertical, WPSpacing.sm)
      .background(WPColor.surface.opacity(0.72))
      .clipShape(.rect(cornerRadius: WPRadius.button))

      if let saveError = viewModel.recordingSaveErrorText {
        Label(saveError, systemImage: "exclamationmark.triangle.fill")
          .font(.wp(.caption))
          .foregroundStyle(WPColor.warning)
          .lineLimit(2)
      }
    }
  }

  private var backgroundCard: some View {
    HStack(spacing: WPSpacing.md) {
      Image(systemName: "moon.zzz.fill")
        .font(.system(size: 20, weight: .semibold))
        .foregroundStyle(WPColor.secondary)

      VStack(alignment: .leading, spacing: WPSpacing.xs) {
        Text("백그라운드 기록")
          .font(.wp(.headline))
          .foregroundStyle(WPColor.ink)

        Text("앱을 닫은 뒤에도 기록하려면 켜주세요.")
          .font(.wp(.subheadline))
          .foregroundStyle(WPColor.muted)
      }

      Spacer()

      Button(action: viewModel.backgroundActionTapped) {
        Image(systemName: "location.north.line.fill")
          .font(.system(size: 16, weight: .semibold))
          .frame(width: 40, height: 40)
      }
      .buttonStyle(.bordered)
      .buttonBorderShape(.roundedRectangle(radius: WPRadius.button))
      .tint(WPColor.secondary)
      .accessibilityLabel("백그라운드 기록 켜기")
    }
    .padding(WPSpacing.md)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(WPColor.secondarySoft)
    .clipShape(.rect(cornerRadius: WPRadius.card))
  }

  private var routeSection: some View {
    VStack(alignment: .leading, spacing: WPSpacing.md) {
      sectionHeader(title: "오늘의 동선", trailing: viewModel.isLoadingTodaySummary ? "불러오는 중" : nil)

      if let error = viewModel.todaySummaryError {
        compactMessage(error, systemImage: "exclamationmark.triangle.fill", color: WPColor.warning)
      } else if viewModel.compactTimelineVisits.isEmpty {
        compactMessage("아직 감지된 방문 기록이 없어요.", systemImage: "calendar", color: WPColor.muted)
      } else {
        VStack(spacing: 0) {
          ForEach(Array(viewModel.compactTimelineVisits.enumerated()), id: \.element.id) { index, visit in
            routeRow(visit: visit, isLast: index == viewModel.compactTimelineVisits.count - 1)
          }
        }
        .padding(.vertical, WPSpacing.sm)
        .background(WPColor.surface)
        .clipShape(.rect(cornerRadius: WPRadius.card))
        .overlay {
          RoundedRectangle(cornerRadius: WPRadius.card)
            .stroke(WPColor.line)
        }
      }
    }
  }

  private var summarySection: some View {
    VStack(alignment: .leading, spacing: WPSpacing.md) {
      sectionHeader(title: "오늘 요약", trailing: nil)

      HStack(spacing: 0) {
        summaryItem(title: "이동 거리", value: viewModel.totalDistanceText)
        Divider()
        summaryItem(title: "방문 장소", value: viewModel.visitedPlaceCountText)
        Divider()
        summaryItem(title: "체류 시간", value: viewModel.totalDurationText)
      }
      .padding(.vertical, WPSpacing.md)
      .background(WPColor.surface)
      .clipShape(.rect(cornerRadius: WPRadius.card))
      .overlay {
        RoundedRectangle(cornerRadius: WPRadius.card)
          .stroke(WPColor.line)
      }
    }
  }

  private func routeRow(visit: Visit, isLast: Bool) -> some View {
    HStack(alignment: .top, spacing: WPSpacing.md) {
      VStack(spacing: WPSpacing.xs) {
        Image(systemName: "location.fill")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(WPColor.primary)
          .frame(width: 34, height: 34)
          .background(WPColor.primarySoft)
          .clipShape(Circle())

        if !isLast {
          Rectangle()
            .fill(WPColor.line)
            .frame(width: 2, height: 18)
        }
      }

      VStack(alignment: .leading, spacing: WPSpacing.xs) {
        Text(visit.placeName)
          .font(.wp(.headline))
          .foregroundStyle(WPColor.ink)
          .lineLimit(1)

        Text(viewModel.timeRangeText(for: visit))
          .font(.wp(.caption))
          .foregroundStyle(WPColor.muted)
      }

      Spacer()

      Text(viewModel.durationText(for: visit))
        .font(.wp(.subheadline))
        .foregroundStyle(WPColor.ink)
    }
    .padding(.horizontal, WPSpacing.md)
    .padding(.vertical, WPSpacing.sm)
  }

  private func summaryItem(title: String, value: String) -> some View {
    VStack(spacing: WPSpacing.xs) {
      Text(title)
        .font(.wp(.caption))
        .foregroundStyle(WPColor.muted)

      Text(value)
        .font(.wp(.headline))
        .foregroundStyle(WPColor.ink)
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity)
  }

  private func liveMetric(title: String, value: String) -> some View {
    VStack(spacing: WPSpacing.xs) {
      Text(title)
        .font(.wp(.caption))
        .foregroundStyle(WPColor.muted)

      Text(value)
        .font(.wp(.subheadline))
        .foregroundStyle(WPColor.ink)
        .lineLimit(1)
        .minimumScaleFactor(0.82)
    }
    .frame(maxWidth: .infinity)
  }

  private func sectionHeader(title: String, trailing: String?) -> some View {
    HStack {
      Text(title)
        .font(.wp(.headline))
        .foregroundStyle(WPColor.ink)

      Spacer()

      if let trailing {
        Text(trailing)
          .font(.wp(.caption))
          .foregroundStyle(WPColor.muted)
      }
    }
  }

  private func compactMessage(_ text: String, systemImage: String, color: Color) -> some View {
    HStack(spacing: WPSpacing.sm) {
      Image(systemName: systemImage)
        .foregroundStyle(color)

      Text(text)
        .font(.wp(.subheadline))
        .foregroundStyle(WPColor.muted)
    }
    .padding(WPSpacing.md)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(WPColor.surface)
    .clipShape(.rect(cornerRadius: WPRadius.card))
    .overlay {
      RoundedRectangle(cornerRadius: WPRadius.card)
        .stroke(WPColor.line)
    }
  }

  private var notificationSystemImage: String {
    viewModel.todaySummaryError == nil ? "bell" : "bell.badge"
  }

  private var statusSystemImage: String {
    if viewModel.recordingSnapshot.isRecording {
      return "dot.radiowaves.left.and.right"
    }

    if !viewModel.todayVisits.isEmpty {
      return "house.fill"
    }

    return viewModel.primaryActionSystemImage
  }
}

#Preview {
  HomeView(
    permissionService: MockLocationPermissionService(),
    recordingService: MockLocationRecordingService(),
    traceRepository: PreviewHomeTraceRepository(),
    visitRepository: PreviewHomeVisitRepository()
  )
}

#Preview("When In Use") {
  HomeView(
    permissionService: MockLocationPermissionService(initialStatus: .whenInUse),
    recordingService: MockLocationRecordingService(),
    traceRepository: PreviewHomeTraceRepository(),
    visitRepository: PreviewHomeVisitRepository()
  )
}

#Preview("Denied") {
  HomeView(
    permissionService: MockLocationPermissionService(initialStatus: .denied),
    recordingService: MockLocationRecordingService(),
    traceRepository: PreviewHomeTraceRepository(),
    visitRepository: PreviewHomeVisitRepository()
  )
}

private struct PreviewHomeTraceRepository: TraceRepository {
  func save(_ trace: TraceRecord) async throws {}

  func recentTraces(limit: Int) async throws -> [TraceRecord] {
    try await traces(on: .now)
  }

  func traces(on date: Date) async throws -> [TraceRecord] {
    [
      TraceRecord(
        point: LocationPoint(
          latitude: 37.5665,
          longitude: 126.9780,
          horizontalAccuracy: 20,
          speed: nil,
          capturedAt: date.addingTimeInterval(-4 * 60 * 60)
        )
      ),
      TraceRecord(
        point: LocationPoint(
          latitude: 37.5702,
          longitude: 126.9828,
          horizontalAccuracy: 18,
          speed: nil,
          capturedAt: date.addingTimeInterval(-2 * 60 * 60)
        )
      )
    ]
  }
}

private struct PreviewHomeVisitRepository: VisitRepository {
  func save(_ visits: [DetectedVisit]) async throws {}

  func visits(on date: Date) async throws -> [Visit] {
    [
      Visit(
        placeName: "집",
        centerPoint: LocationPoint(latitude: 37.5665, longitude: 126.9780, horizontalAccuracy: 15, speed: nil),
        startedAt: date.addingTimeInterval(-4 * 60 * 60),
        endedAt: date.addingTimeInterval(-2 * 60 * 60 - 10 * 60),
        durationMinutes: 110,
        confidence: 0.92
      ),
      Visit(
        placeName: "회사",
        centerPoint: LocationPoint(latitude: 37.5702, longitude: 126.9828, horizontalAccuracy: 18, speed: nil),
        startedAt: date.addingTimeInterval(-90 * 60),
        endedAt: date.addingTimeInterval(-35 * 60),
        durationMinutes: 55,
        confidence: 0.87
      )
    ]
  }
}
