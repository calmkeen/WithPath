//
//  HomeView.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel: HomeViewModel

  init(permissionService: any LocationPermissionServicing) {
    _viewModel = StateObject(wrappedValue: HomeViewModel(permissionService: permissionService))
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: WPSpacing.lg) {
          header

          permissionCard

          if viewModel.showsBackgroundAction {
            backgroundCard
          }

          privacyCard
        }
        .padding(WPSpacing.lg)
      }
      .background(WPColor.background)
      .navigationTitle("오늘")
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: WPSpacing.md) {
      Text("오늘의 동선")
        .font(.wp(.largeTitle))
        .foregroundStyle(WPColor.ink)

      HStack(spacing: WPSpacing.sm) {
        Image(systemName: "dot.radiowaves.left.and.right")
          .foregroundStyle(WPColor.primary)

        Text(viewModel.recordingStateText)
          .font(.wp(.subheadline))
          .foregroundStyle(WPColor.primary)
      }
      .padding(.horizontal, WPSpacing.md)
      .padding(.vertical, WPSpacing.sm)
      .background(WPColor.primarySoft)
      .clipShape(.rect(cornerRadius: WPRadius.button))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var permissionCard: some View {
    VStack(alignment: .leading, spacing: WPSpacing.lg) {
      HStack(alignment: .top, spacing: WPSpacing.md) {
        Image(systemName: "location.circle.fill")
          .font(.system(size: 36, weight: .semibold))
          .foregroundStyle(WPColor.primary)

        VStack(alignment: .leading, spacing: WPSpacing.sm) {
          Text(viewModel.statusTitle)
            .font(.wp(.title2))
            .foregroundStyle(WPColor.ink)

          Text(viewModel.statusDescription)
            .font(.wp(.body))
            .foregroundStyle(WPColor.muted)
            .fixedSize(horizontal: false, vertical: true)
        }
      }

      Button(action: viewModel.primaryActionTapped) {
        Label(viewModel.primaryActionTitle, systemImage: viewModel.primaryActionSystemImage)
          .font(.wp(.headline))
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .buttonBorderShape(.roundedRectangle(radius: WPRadius.button))
      .controlSize(.large)
      .tint(WPColor.primary)
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

  private var backgroundCard: some View {
    VStack(alignment: .leading, spacing: WPSpacing.md) {
      HStack(spacing: WPSpacing.md) {
        Image(systemName: "moon.zzz.fill")
          .font(.system(size: 24, weight: .semibold))
          .foregroundStyle(WPColor.secondary)

        VStack(alignment: .leading, spacing: WPSpacing.xs) {
          Text("백그라운드 기록")
            .font(.wp(.headline))
            .foregroundStyle(WPColor.ink)

          Text("앱을 닫은 뒤에도 이동과 체류를 이어서 기록하려면 별도 권한이 필요합니다.")
            .font(.wp(.subheadline))
            .foregroundStyle(WPColor.muted)
        }
      }

      Button(action: viewModel.backgroundActionTapped) {
        Label("백그라운드 기록 켜기", systemImage: "location.north.line.fill")
          .font(.wp(.headline))
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bordered)
      .buttonBorderShape(.roundedRectangle(radius: WPRadius.button))
      .controlSize(.large)
      .tint(WPColor.secondary)
    }
    .padding(WPSpacing.lg)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(WPColor.secondarySoft)
    .clipShape(.rect(cornerRadius: WPRadius.card))
  }

  private var privacyCard: some View {
    VStack(alignment: .leading, spacing: WPSpacing.md) {
      Label("기록은 먼저 내 기기에 저장됩니다.", systemImage: "lock.fill")
        .font(.wp(.headline))
        .foregroundStyle(WPColor.ink)

      Text("공유는 나중에 직접 켜는 기능이며, 기본 기록은 비공개 상태로 시작합니다.")
        .font(.wp(.body))
        .foregroundStyle(WPColor.muted)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(WPSpacing.lg)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(WPColor.accentSoft)
    .clipShape(.rect(cornerRadius: WPRadius.card))
  }
}

#Preview {
  HomeView(permissionService: MockLocationPermissionService())
}

#Preview("When In Use") {
  HomeView(permissionService: MockLocationPermissionService(initialStatus: .whenInUse))
}

#Preview("Denied") {
  HomeView(permissionService: MockLocationPermissionService(initialStatus: .denied))
}
