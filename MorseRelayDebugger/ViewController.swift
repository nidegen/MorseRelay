//
//  ViewController.swift
//  MorseRelayDebugger
//
//  Created by Nicolas Degen on 11.10.18.
//  Copyright © 2018 nide. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  let frameProcessor = FrameProcessor()
  let cameraManager: CameraManager!
  
  let textOutput = NSTextView(frame: .zero)
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    cameraManager = CameraManager(captureDelegate: frameProcessor)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    cameraManager = CameraManager(captureDelegate: frameProcessor)
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    frameProcessor.setWordDetectedCallback { word in
      DispatchQueue.main.async {
        self.textOutput.string = self.textOutput.string + "" + word!
      }
    }
    
    frameProcessor.setSymbolDetectedCallback { symbol in
      DispatchQueue.main.async {
        self.textOutput.string = self.textOutput.string + symbol!
      }
    }
    
    frameProcessor.setSignalDetectionEventCallback { detectedSignal in
      DispatchQueue.main.async {
        if detectedSignal {
          // Detected signal switch on
          self.textOutput.backgroundColor = .yellow
          print(11)
        } else {
          // Detected signal switch off
          self.textOutput.backgroundColor = .clear
          print(00)
        }
      }
    }
    
    cameraManager.setupCamera()
    
    let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.captureSession)
    previewLayer.frame = view.bounds
    previewLayer.backgroundColor = NSColor.black.cgColor
    previewLayer.videoGravity = .resizeAspectFill
    view.layer?.insertSublayer(previewLayer, at: 0)
  }
  
  override func loadView() {
    super.loadView()
    
    textOutput.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(textOutput)
    textOutput.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    textOutput.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    textOutput.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    textOutput.heightAnchor.constraint(equalToConstant: 40).isActive = true
  }
}

