//
//  WithPathApp.swift
//  WithPath
//
//  Created by calmkeen on 4/26/26.
//

import SwiftUI

@main
struct WithPathApp: App {
  @UIApplicationDelegateAdaptor(WithPathAppDelegate.self) private var appDelegate

  private let environment = AppEnvironment.live()

  var body: some Scene {
    WindowGroup {
      AppRootView(environment: environment)
    }
  }
}
