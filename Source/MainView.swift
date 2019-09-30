//
//  MainView.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 27.09.19.
//  Copyright © 2019 nide. All rights reserved.
//

import SwiftUI

struct MainView: View {
  @State private var selection = 0
  
  init() {
    UITabBar().barStyle = .black
  }
  
  var body: some View {
    TabView(selection: $selection) {
      EncoderView().tag(0)
      EncoderView().tag(1)
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
