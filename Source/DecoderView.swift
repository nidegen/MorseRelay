//
//  DecoderView.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 03.02.20.
//  Copyright © 2020 nide. All rights reserved.
//

import SwiftUI

import CameraKit

struct DecoderView: View {
  @State var decodedText = ""
  
  var cameraManager: CameraManager
  
  var body: some View {
    ZStack {
      CameraView(cameraManager: cameraManager)
      VStack {
        HStack {
          Text(decodedText)
          VStack {
            Text("Start")
            Text("Stop")
          }
        }
      }
    }
    .tabItem {
      VStack {
        Image(systemName: "camera.fill")
        Text("Camera")
      }
    }
  }
}

struct DecoderView_Previews: PreviewProvider {
  static var previews: some View {
    DecoderView(cameraManager: CameraManager())
  }
}
