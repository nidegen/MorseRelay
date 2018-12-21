//
//  NSDecoderViewController.swift
//  MorseRelayDebugger
//
//  Created by Nicolas Degen on 11.10.18.
//  Copyright © 2018 nide. All rights reserved.
//

import Cocoa

class NSDecoderViewController: NSViewController {
  let frameProcessor = FrameProcessor()
  let cameraManager: CameraManager!
  var previewLayer: AVCaptureVideoPreviewLayer?
  
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
        print(word!)
      }
    }
    
    frameProcessor.setSymbolDetectedCallback { symbol in
      DispatchQueue.main.async {
        self.textOutput.string = self.textOutput.string + symbol!
        print(symbol!)
      }
    }
    
    frameProcessor.setSignalDetectionEventCallback { detectedSignal in
      DispatchQueue.main.async {
        if detectedSignal {
          // Detected signal switch on
          self.textOutput.backgroundColor = .yellow
//          print("On")
        } else {
          // Detected signal switch off
          self.textOutput.backgroundColor = .clear
//          print("Off")
        }
      }
    }
    
    cameraManager.setupCamera()
  }
  
  override func viewDidAppear() {
    if (previewLayer == nil) {
      previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.captureSession)
      previewLayer!.frame = view.bounds
      previewLayer!.backgroundColor = NSColor.black.cgColor
      previewLayer!.videoGravity = .resizeAspectFill
      view.layer?.insertSublayer(previewLayer!, at: 0)
    }
    cameraManager.startCamera()
  }
  
  override func viewDidLayout() {
    super.viewDidLayout()
    
    previewLayer?.frame = view.bounds;
  }
  
  override func viewWillDisappear() {
    cameraManager.stopCamera()
  }
  
  override func loadView() {
    super.loadView()
    
    textOutput.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(textOutput)
    textOutput.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    textOutput.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
    textOutput.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    textOutput.heightAnchor.constraint(equalToConstant: 40).isActive = true
    textOutput.backgroundColor = .white
    
    let hudView = NSImageView(image: NSImage(named: "HUDImage")!)
    hudView.imageAlignment = .alignCenter
    view.addSubview(hudView)
    hudView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([hudView.heightAnchor.constraint(equalTo: view.heightAnchor),
                                 hudView.widthAnchor.constraint(equalTo: view.widthAnchor),
                                 hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                 hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
  }
}

