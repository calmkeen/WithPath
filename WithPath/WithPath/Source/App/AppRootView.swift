//
//  AppRootView.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import SwiftUI

struct AppRootView: View {
  let environment: AppEnvironment

  var body: some View {
    MainTabView(environment: environment)
  }
}

#Preview {
  AppRootView(environment: .preview())
}
