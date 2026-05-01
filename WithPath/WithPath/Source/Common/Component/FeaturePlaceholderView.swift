//
//  FeaturePlaceholderView.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import SwiftUI

struct FeaturePlaceholderView: View {
  let title: String
  let systemImage: String
  let status: String

  var body: some View {
    NavigationStack {
      ZStack {
        WPColor.background
          .ignoresSafeArea()

        VStack(spacing: WPSpacing.md) {
          Image(systemName: systemImage)
            .font(.system(size: 32, weight: .semibold))
            .foregroundStyle(WPColor.primary)
            .frame(width: 64, height: 64)
            .background(WPColor.primarySoft)
            .clipShape(.rect(cornerRadius: WPRadius.icon))

          VStack(spacing: WPSpacing.sm) {
            Text(title)
              .font(.wp(.title))
              .foregroundStyle(WPColor.ink)

            Text(status)
              .font(.wp(.body))
              .foregroundStyle(WPColor.muted)
              .multilineTextAlignment(.center)
          }
        }
        .padding(WPSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(WPColor.surface)
        .clipShape(.rect(cornerRadius: WPRadius.card))
        .overlay(
          RoundedRectangle(cornerRadius: WPRadius.card)
            .stroke(WPColor.line)
        )
        .padding(WPSpacing.lg)
      }
      .navigationTitle(title)
    }
  }
}

#Preview {
  FeaturePlaceholderView(
    title: "오늘",
    systemImage: "figure.walk",
    status: "기록 준비 중"
  )
}
