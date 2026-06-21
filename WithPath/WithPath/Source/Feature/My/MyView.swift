//
//  MyView.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import SwiftUI

struct MyView: View {
  private let profile = MyProfile(
    nickname: "게스트",
    loginState: "로그인 필요",
    systemImage: "person.crop.circle.fill"
  )

  private let sections: [MySection] = [
    MySection(
      title: "기본 설정",
      rows: [
        MyRow(title: "닉네임 변경", systemImage: "pencil"),
        MyRow(title: "저장 장소", systemImage: "mappin.and.ellipse", value: "0개"),
        MyRow(title: "GPS 절전", systemImage: "battery.75percent", value: "균형"),
        MyRow(title: "공개 범위", systemImage: "lock.shield", value: "비공개"),
        MyRow(title: "민감 장소", systemImage: "eye.slash")
      ]
    ),
    MySection(
      title: "정보 및 동의",
      rows: [
        MyRow(title: "약관 및 개인정보 동의", systemImage: "doc.text"),
        MyRow(title: "시스템 정보", systemImage: "gearshape"),
        MyRow(title: "앱 정보", systemImage: "info.circle"),
        MyRow(title: "탈퇴하기", systemImage: "person.crop.circle.badge.xmark", role: .destructive)
      ]
    )
  ]

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: WPSpacing.lg) {
          MyProfileSection(profile: profile)

          ForEach(sections) { section in
            MySettingsSection(section: section)
          }
        }
        .padding(WPSpacing.lg)
      }
      .background(WPColor.background)
      .navigationTitle("MY")
    }
  }
}

#Preview {
  MyView()
}

private struct MyProfile: Identifiable {
  let id = UUID()
  let nickname: String
  let loginState: String
  let systemImage: String
}

private struct MySection: Identifiable {
  let id = UUID()
  let title: String
  let rows: [MyRow]
}

private struct MyRow: Identifiable {
  let id = UUID()
  let title: String
  let systemImage: String
  var value: String?
  var role: MyRowRole = .normal
}

private enum MyRowRole {
  case normal
  case destructive

  var foregroundColor: Color {
    switch self {
    case .normal:
      return WPColor.ink
    case .destructive:
      return WPColor.danger
    }
  }

  var iconColor: Color {
    switch self {
    case .normal:
      return WPColor.primary
    case .destructive:
      return WPColor.danger
    }
  }
}

private struct MyProfileSection: View {
  let profile: MyProfile

  var body: some View {
    Button {
      // TODO: Connect to login flow when account feature is introduced.
    } label: {
      HStack(spacing: WPSpacing.md) {
        Image(systemName: profile.systemImage)
          .font(.system(size: 32, weight: .semibold))
          .foregroundStyle(WPColor.primary)
          .frame(width: 56, height: 56)
          .background(WPColor.primarySoft)
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: WPSpacing.xs) {
          Text(profile.nickname)
            .font(.wp(.title2))
            .foregroundStyle(WPColor.ink)

          Text(profile.loginState)
            .font(.wp(.subheadline))
            .foregroundStyle(WPColor.muted)
        }

        Spacer(minLength: WPSpacing.sm)

        Image(systemName: "chevron.right")
          .font(.wp(.captionBold))
          .foregroundStyle(WPColor.muted)
      }
      .padding(WPSpacing.md)
      .background(WPColor.surface)
      .clipShape(.rect(cornerRadius: WPRadius.card))
      .overlay {
        RoundedRectangle(cornerRadius: WPRadius.card)
          .stroke(WPColor.line)
      }
    }
    .buttonStyle(.plain)
  }
}

private struct MySettingsSection: View {
  let section: MySection

  var body: some View {
    VStack(alignment: .leading, spacing: WPSpacing.sm) {
      Text(section.title)
        .font(.wp(.captionBold))
        .foregroundStyle(WPColor.muted)
        .padding(.horizontal, WPSpacing.sm)

      VStack(spacing: 0) {
        ForEach(Array(section.rows.enumerated()), id: \.element.id) { index, row in
          MySettingsRow(row: row)

          if index < section.rows.count - 1 {
            Divider()
              .padding(.leading, 52)
          }
        }
      }
      .background(WPColor.surface)
      .clipShape(.rect(cornerRadius: WPRadius.card))
      .overlay {
        RoundedRectangle(cornerRadius: WPRadius.card)
          .stroke(WPColor.line)
      }
    }
  }
}

private struct MySettingsRow: View {
  let row: MyRow

  var body: some View {
    Button {
      // TODO: Route each setting once destination screens are available.
    } label: {
      HStack(spacing: WPSpacing.md) {
        Image(systemName: row.systemImage)
          .font(.wp(.headline))
          .foregroundStyle(row.role.iconColor)
          .frame(width: 28, height: 28)

        Text(row.title)
          .font(.wp(.bodyMedium))
          .foregroundStyle(row.role.foregroundColor)

        Spacer(minLength: WPSpacing.sm)

        if let value = row.value {
          Text(value)
            .font(.wp(.subheadline))
            .foregroundStyle(WPColor.muted)
        }

        Image(systemName: "chevron.right")
          .font(.wp(.captionBold))
          .foregroundStyle(WPColor.muted)
      }
      .padding(.horizontal, WPSpacing.md)
      .padding(.vertical, WPSpacing.md)
    }
    .buttonStyle(.plain)
  }
}
