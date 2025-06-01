//
//  MainTabView.swift
//  MovieMatch
//
//  Created by Jaineel Modi on 2025-05-30.
//

import SwiftUI

struct MainTabView: View {
  var body: some View {
    TabView {
      MainSwipeView()
        .tabItem {
          Image(systemName: "xmark.circle")
          Text("Swipe")
        }

      RecommendationsView()
        .tabItem {
          Image(systemName: "sparkles")
          Text("Recs")
        }

      ProfileView()
        .tabItem {
          Image(systemName: "person.crop.circle")
          Text("Profile")
        }
    }
    .accentColor(.red)              // match your theme
    .background(Color.black)        // ensure true black behind tabs
  }
}

struct MainTabView_Previews: PreviewProvider {
  static var previews: some View {
    MainTabView()
      .preferredColorScheme(.dark)
  }
}
