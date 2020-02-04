//
//  ContentView.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 03.02.20.
//  Copyright © 2020 nide. All rights reserved.
//

import SwiftUI

import CameraKit

struct ContentView: View {
  var cameraManager = CameraManager()
  @State var selectedTab = 0
  
  init() {
    cameraManager.setupCamera()
    cameraManager.startCamera()
  }
  var body: some View {
    TabView(selection: $selectedTab) {
      DecoderView(cameraManager: cameraManager).tag(0)
    }
    .edgesIgnoringSafeArea(.top)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
