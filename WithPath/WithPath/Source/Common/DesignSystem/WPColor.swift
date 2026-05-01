//
//  WPColor.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import SwiftUI
import UIKit

enum WPPrimitiveColor {
  static let blue500 = UIColor(hex: "2F6BFF")
  static let blue700 = UIColor(hex: "1746C9")
  static let purple500 = UIColor(hex: "7C5CFF")
  static let green500 = UIColor(hex: "22C55E")
  static let orange500 = UIColor(hex: "F59E0B")
  static let red500 = UIColor(hex: "EF4444")

  static let gray50 = UIColor(hex: "F7F9FC")
  static let white = UIColor(hex: "FFFFFF")
  static let gray900 = UIColor(hex: "111827")
  static let gray500 = UIColor(hex: "667085")
  static let gray200 = UIColor(hex: "E5E7EB")

  static let blue50 = UIColor(hex: "EAF1FF")
  static let purple50 = UIColor(hex: "F1EDFF")
  static let green50 = UIColor(hex: "E9FBEF")
}

enum WPUIColor {
  // Brand
  static let primary = WPPrimitiveColor.blue500
  static let primaryDark = WPPrimitiveColor.blue700
  static let secondary = WPPrimitiveColor.purple500

  // State
  static let accent = WPPrimitiveColor.green500
  static let success = WPPrimitiveColor.green500
  static let warning = WPPrimitiveColor.orange500
  static let danger = WPPrimitiveColor.red500
  static let error = WPPrimitiveColor.red500

  // Background
  static let background = WPPrimitiveColor.gray50
  static let surface = WPPrimitiveColor.white

  // Text
  static let ink = WPPrimitiveColor.gray900
  static let muted = WPPrimitiveColor.gray500

  // Border
  static let line = WPPrimitiveColor.gray200

  // Soft surfaces
  static let primarySoft = WPPrimitiveColor.blue50
  static let secondarySoft = WPPrimitiveColor.purple50
  static let accentSoft = WPPrimitiveColor.green50

  // Route
  static let routeStart = WPPrimitiveColor.blue500
  static let routeEnd = WPPrimitiveColor.purple500
  static let routeActive = WPPrimitiveColor.green500

  // Compatibility aliases
  static let textPrimary = ink
  static let textSecondary = muted
  static let border = line
}

enum WPColor {
  // Brand
  static let primary = Color(uiColor: WPUIColor.primary)
  static let primaryDark = Color(uiColor: WPUIColor.primaryDark)
  static let secondary = Color(uiColor: WPUIColor.secondary)

  // State
  static let accent = Color(uiColor: WPUIColor.accent)
  static let success = Color(uiColor: WPUIColor.success)
  static let warning = Color(uiColor: WPUIColor.warning)
  static let danger = Color(uiColor: WPUIColor.danger)
  static let error = Color(uiColor: WPUIColor.error)

  // Background
  static let background = Color(uiColor: WPUIColor.background)
  static let surface = Color(uiColor: WPUIColor.surface)

  // Text
  static let ink = Color(uiColor: WPUIColor.ink)
  static let muted = Color(uiColor: WPUIColor.muted)

  // Border
  static let line = Color(uiColor: WPUIColor.line)

  // Soft surfaces
  static let primarySoft = Color(uiColor: WPUIColor.primarySoft)
  static let secondarySoft = Color(uiColor: WPUIColor.secondarySoft)
  static let accentSoft = Color(uiColor: WPUIColor.accentSoft)

  // Route
  static let routeStart = Color(uiColor: WPUIColor.routeStart)
  static let routeEnd = Color(uiColor: WPUIColor.routeEnd)
  static let routeActive = Color(uiColor: WPUIColor.routeActive)

  // Compatibility aliases
  static let textPrimary = ink
  static let textSecondary = muted
  static let border = line
}

extension UIColor {
  convenience init(hex: String, alpha: CGFloat = 1.0) {
    let hexString = hex
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "#", with: "")

    var rgb: UInt64 = 0
    Scanner(string: hexString).scanHexInt64(&rgb)

    let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
    let blue = CGFloat(rgb & 0x0000FF) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
