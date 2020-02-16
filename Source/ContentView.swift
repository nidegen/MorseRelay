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
  var frameProcessor = FrameProcessor()
  
  @State var selectedTab = 0
  @ObservedObject var frameProcessorObserver: FrameProcessorObserver
  
  init() {
    self.cameraManager.setupCamera()
    self.cameraManager.startCamera()
    self.cameraManager.sampleBufferOutputDelegate = self.frameProcessor
    frameProcessorObserver = FrameProcessorObserver(frameProcessor: self.frameProcessor)
  }
  
  var body: some View {
    TabView(selection: $selectedTab) {
      DecoderView(decodedText: $frameProcessorObserver.currentText, isProcessing: $frameProcessorObserver.isProcessing, currentSignalState: $frameProcessorObserver.currentSignalState, cameraManager: CameraManager()).tag(0)
      EncoderView().tag(1)
    }
    .edgesIgnoringSafeArea(.top)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
