//
//  CameraPreviewController.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 11.07.18.
//  Copyright © 2018 nide. All rights reserved.
//
import UIKit
import AVFoundation
import CoreImage

class CameraPreviewController: UIViewController {
  
  var textOutput: UITextField!
  
  // MARK: - Properties
  
  lazy var captureSession: AVCaptureSession = {
    let session = AVCaptureSession()
    session.sessionPreset = .high
    return session
  }()
  
  let frameProcessor = FrameProcessor()
  
  var previewLayer: AVCaptureVideoPreviewLayer?
  
  let sampleBufferQueue = DispatchQueue.global(qos: .userInteractive)
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
      setupCaptureSession()
    } else {
      AVCaptureDevice.requestAccess(for: .video, completionHandler: { (authorized) in
        DispatchQueue.main.async {
          if authorized {
            self.setupCaptureSession()
          }
        }
      })
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    previewLayer?.bounds = view.frame
  }
  
  // MARK: - Rotation
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait]
  }
  
  // MARK: - Camera Capture
  
  private func findCamera() -> AVCaptureDevice? {
    let deviceTypes: [AVCaptureDevice.DeviceType] = [
      .builtInDualCamera,
      .builtInTelephotoCamera,
      .builtInWideAngleCamera
    ]
    
    let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                     mediaType: .video,
                                                     position: .back)
    
    return discovery.devices.first
  }
  
  private func setupCaptureSession() {
    guard captureSession.inputs.isEmpty else { return }
    guard let camera = findCamera() else {
      print("No camera found")
      return
    }
    
    do {
      let cameraInput = try AVCaptureDeviceInput(device: camera)
      captureSession.addInput(cameraInput)
      
      let preview = AVCaptureVideoPreviewLayer(session: captureSession)
      preview.frame = view.bounds
      preview.backgroundColor = UIColor.black.cgColor
      preview.videoGravity = .resizeAspect
      view.layer.addSublayer(preview)
      self.previewLayer = preview
      
      let output = AVCaptureVideoDataOutput()
      output.alwaysDiscardsLateVideoFrames = true
      output.setSampleBufferDelegate(frameProcessor, queue: sampleBufferQueue)
      
      for pixelType in output.availableVideoPixelFormatTypes {
        if pixelType == kCVPixelFormatType_32BGRA {
          
        }
        if (pixelType == kCVPixelFormatType_32BGRA) || (pixelType == kCVPixelFormatType_32RGBA) {
          var videoSettings = [String : Any]()
          videoSettings[kCVPixelBufferPixelFormatTypeKey as String] =  pixelType
          output.videoSettings = videoSettings
          break
        }
      }
      
      captureSession.addOutput(output)
      
      captureSession.startRunning()
      
    } catch let error {
      print("Error creating capture session: \(error)")
      return
    }
  }
  
  override func loadView() {
    super.loadView()
    textOutput = UITextField(frame: .zero)
    frameProcessor.setWordDetectedCallback { word in
      self.textOutput.text = (self.textOutput.text ?? "") + "" + word!
    }
    frameProcessor.setSymbolDetectedCallback { symbol in
      self.textOutput.text = (self.textOutput.text ?? "") + symbol!
    }
  }
}

func toggleTorch(on: Bool) {
  guard let device = AVCaptureDevice.default(for: .video) else { return }
  
  if device.hasTorch {
    do {
      try device.lockForConfiguration()
      
      if on == true {
        device.torchMode = .on
      } else {
        device.torchMode = .off
      }
      
      device.unlockForConfiguration()
    } catch {
      print("Torch could not be used")
    }
  } else {
    print("Torch is not available")
  }
}
