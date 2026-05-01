//
//  WPFont.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import Foundation
import SwiftUI

enum WPFont {
  static func font(_ style: WPTextStyle) -> Font {
    .system(
      size: style.size,
      weight: style.weight,
      design: .default
    )
  }
}

enum WPTextStyle {
  case largeTitle
  case title
  case title2
  case headline
  case body
  case bodyMedium
  case subheadline
  case caption
  case captionBold
  case tab

  var size: CGFloat {
    switch self {
    case .largeTitle:
      return 34
    case .title:
      return 24
    case .title2:
      return 22
    case .headline:
      return 17
    case .body, .bodyMedium:
      return 16
    case .subheadline:
      return 15
    case .caption, .captionBold:
      return 12
    case .tab:
      return 11
    }
  }

  var weight: Font.Weight {
    switch self {
    case .largeTitle, .title, .title2:
      return .bold
    case .headline, .tab:
      return .semibold
    case .bodyMedium, .captionBold:
      return .medium
    case .body, .subheadline, .caption:
      return .regular
    }
  }
}

extension Font {
  static func wp(_ style: WPTextStyle) -> Font {
    WPFont.font(style)
  }
}
