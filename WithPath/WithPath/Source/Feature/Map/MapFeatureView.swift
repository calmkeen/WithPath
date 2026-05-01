//
//  MapFeatureView.swift
//  WithPath
//
//  Created by calmkeen on 4/30/26.
//

import SwiftUI

struct MapFeatureView: View {
  var body: some View {
    FeaturePlaceholderView(
      title: "지도",
      systemImage: "map",
      status: "MapKit 경로 화면 준비 중"
    )
  }
}

#Preview {
  MapFeatureView()
}
