//
//  FrameProcessorObserver.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 16.02.20.
//  Copyright © 2020 nide. All rights reserved.
//

import Combine

class FrameProcessorObserver: ObservableObject {
  @Published var currentWord = ""
  @Published var currentText = ""
  @Published var currentSignalState = false
  @Published var isProcessing = false
  
  var processingCancellable: AnyCancellable?

  let frameProcessor: FrameProcessor
  
  init(frameProcessor: FrameProcessor) {
    self.frameProcessor = frameProcessor
    frameProcessor.setWordDetectedCallback { word in
      DispatchQueue.main.async {
        self.currentText += " " + (word ?? "")
        self.currentWord = ""
      }
    }
    
    frameProcessor.setSymbolDetectedCallback { symbol in
      DispatchQueue.main.async {
        self.currentWord += symbol ?? ""
      }
    }
    
    frameProcessor.setSignalDetectionEventCallback { detectedSignal in
      DispatchQueue.main.async {
        self.currentSignalState = detectedSignal
      }
    }
    processingCancellable = self.$isProcessing.sink { isProcessing in
      if isProcessing {
        frameProcessor.startProcessing()
      } else {
        frameProcessor.stopProcessing()
      }
    }
  }
}
