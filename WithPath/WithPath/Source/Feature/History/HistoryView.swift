//
//  HistoryView.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import SwiftUI

struct HistoryView: View {
  let isActive: Bool

  @StateObject private var viewModel: HistoryViewModel

  init(visitRepository: any VisitRepository, isActive: Bool) {
    self.isActive = isActive
    _viewModel = StateObject(
      wrappedValue: HistoryViewModel(visitRepository: visitRepository)
    )
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: WPSpacing.lg) {
          header

          summaryStrip

          content
        }
        .padding(WPSpacing.lg)
      }
      .background(WPColor.background)
      .navigationTitle("기록")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            Task {
              await viewModel.reload()
            }
          } label: {
            Image(systemName: "arrow.clockwise")
          }
          .accessibilityLabel("기록 새로고침")
        }
      }
      .task(id: isActive) {
        guard isActive else { return }
        await viewModel.loadIfNeeded()
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: WPSpacing.sm) {
      Text("오늘의 기록")
        .font(.wp(.largeTitle))
        .foregroundStyle(WPColor.ink)

      Text(viewModel.dateTitle)
        .font(.wp(.subheadline))
        .foregroundStyle(WPColor.muted)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var summaryStrip: some View {
    HStack(spacing: WPSpacing.md) {
      summaryItem(title: "방문", value: viewModel.visitCountText, systemImage: "mappin.and.ellipse")

      Divider()

      summaryItem(title: "체류", value: viewModel.totalDurationText, systemImage: "clock.fill")
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

  private var content: some View {
    Group {
      if viewModel.isLoading {
        loadingView
      } else if let errorMessage = viewModel.errorMessage {
        messageView(
          title: "기록을 불러오지 못했어요",
          subtitle: errorMessage,
          systemImage: "exclamationmark.triangle.fill",
          color: WPColor.warning
        )
      } else if viewModel.hasVisits {
        timelineList
      } else {
        messageView(
          title: "아직 오늘 방문 기록이 없어요",
          subtitle: "오늘 감지된 체류 지점이 없습니다.",
          systemImage: "calendar",
          color: WPColor.muted
        )
      }
    }
  }

  private var loadingView: some View {
    HStack(spacing: WPSpacing.md) {
      ProgressView()
        .tint(WPColor.primary)

      Text("오늘 기록 불러오는 중")
        .font(.wp(.headline))
        .foregroundStyle(WPColor.ink)
    }
    .padding(WPSpacing.lg)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(WPColor.surface)
    .clipShape(.rect(cornerRadius: WPRadius.card))
  }

  private var timelineList: some View {
    VStack(alignment: .leading, spacing: WPSpacing.md) {
      ForEach(Array(viewModel.visits.enumerated()), id: \.element.id) { index, visit in
        timelineRow(
          visit: visit,
          isLast: index == viewModel.visits.count - 1
        )
      }
    }
  }

  private func timelineRow(visit: Visit, isLast: Bool) -> some View {
    HStack(alignment: .top, spacing: WPSpacing.md) {
      VStack(spacing: 0) {
        Circle()
          .fill(WPColor.primary)
          .frame(width: 12, height: 12)
          .padding(.top, WPSpacing.lg)

        if !isLast {
          Rectangle()
            .fill(WPColor.line)
            .frame(width: 2, height: 76)
        }
      }
      .frame(width: 18)

      visitCard(visit)
    }
  }

  private func visitCard(_ visit: Visit) -> some View {
    VStack(alignment: .leading, spacing: WPSpacing.md) {
      HStack(alignment: .top, spacing: WPSpacing.md) {
        Image(systemName: "location.fill")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(WPColor.primary)
          .frame(width: 28, height: 28)
          .background(WPColor.primarySoft)
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: WPSpacing.xs) {
          Text(visit.placeName)
            .font(.wp(.headline))
            .foregroundStyle(WPColor.ink)
            .lineLimit(1)

          Text(viewModel.timeRangeText(for: visit))
            .font(.wp(.subheadline))
            .foregroundStyle(WPColor.muted)
        }

        Spacer(minLength: WPSpacing.sm)
      }

      HStack(spacing: WPSpacing.sm) {
        infoChip(viewModel.durationText(for: visit), systemImage: "clock")
        infoChip(viewModel.confidenceText(for: visit), systemImage: "checkmark.seal")
      }
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

  private func summaryItem(title: String, value: String, systemImage: String) -> some View {
    HStack(spacing: WPSpacing.sm) {
      Image(systemName: systemImage)
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(WPColor.primary)
        .frame(width: 28, height: 28)

      VStack(alignment: .leading, spacing: WPSpacing.xs) {
        Text(title)
          .font(.wp(.caption))
          .foregroundStyle(WPColor.muted)

        Text(value)
          .font(.wp(.headline))
          .foregroundStyle(WPColor.ink)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func infoChip(_ text: String, systemImage: String) -> some View {
    Label(text, systemImage: systemImage)
      .font(.wp(.captionBold))
      .foregroundStyle(WPColor.primary)
      .padding(.horizontal, WPSpacing.sm)
      .padding(.vertical, WPSpacing.xs)
      .background(WPColor.primarySoft)
      .clipShape(.rect(cornerRadius: WPRadius.button))
  }

  private func messageView(
    title: String,
    subtitle: String,
    systemImage: String,
    color: Color
  ) -> some View {
    VStack(alignment: .leading, spacing: WPSpacing.md) {
      Image(systemName: systemImage)
        .font(.system(size: 28, weight: .semibold))
        .foregroundStyle(color)

      VStack(alignment: .leading, spacing: WPSpacing.xs) {
        Text(title)
          .font(.wp(.headline))
          .foregroundStyle(WPColor.ink)

        Text(subtitle)
          .font(.wp(.body))
          .foregroundStyle(WPColor.muted)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(WPSpacing.lg)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(WPColor.surface)
    .clipShape(.rect(cornerRadius: WPRadius.card))
    .overlay {
      RoundedRectangle(cornerRadius: WPRadius.card)
        .stroke(WPColor.line)
    }
  }
}

#Preview {
  HistoryView(visitRepository: PreviewVisitRepository(), isActive: true)
}

private struct PreviewVisitRepository: VisitRepository {
  func save(_ visits: [DetectedVisit]) async throws {}

  func visits(on date: Date) async throws -> [Visit] {
    [
      Visit(
        placeName: "37.56650, 126.97800",
        centerPoint: LocationPoint(latitude: 37.5665, longitude: 126.9780, horizontalAccuracy: 15, speed: nil),
        startedAt: date.addingTimeInterval(-3 * 60 * 60),
        endedAt: date.addingTimeInterval(-2 * 60 * 60 - 18 * 60),
        durationMinutes: 42,
        confidence: 0.91
      ),
      Visit(
        placeName: "37.56930, 126.98220",
        centerPoint: LocationPoint(latitude: 37.5693, longitude: 126.9822, horizontalAccuracy: 18, speed: nil),
        startedAt: date.addingTimeInterval(-90 * 60),
        endedAt: date.addingTimeInterval(-42 * 60),
        durationMinutes: 48,
        confidence: 0.86
      )
    ]
  }
}
