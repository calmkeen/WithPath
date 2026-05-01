//
//  MainTabView.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import SwiftUI

struct MainTabView: View {
  let environment: AppEnvironment

  @State private var selectedTab: MainTab = .home

  var body: some View {
    TabView(selection: $selectedTab) {
      HomeView()
        .tabItem {
          Label("오늘", systemImage: "house.fill")
        }
        .tag(MainTab.home)

      MapFeatureView()
        .tabItem {
          Label("지도", systemImage: "map.fill")
        }
        .tag(MainTab.map)

      WithView()
        .tabItem {
          Label("함께", systemImage: "person.2.fill")
        }
        .tag(MainTab.with)

      HistoryView()
        .tabItem {
          Label("기록", systemImage: "chart.bar.fill")
        }
        .tag(MainTab.history)

      MyView()
        .tabItem {
          Label("MY", systemImage: "person.crop.circle.fill")
        }
        .tag(MainTab.my)
    }
    .tint(WPColor.primary)
  }
}

#Preview {
  MainTabView(environment: .preview())
}
