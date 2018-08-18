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
    
    frameProcessor.setWordDetectedCallback { word in
      DispatchQueue.main.async {
        self.navigationItem.title = word
        self.textOutput.text = (self.textOutput.text ?? "") + "" + word!
      }
    }
    
    frameProcessor.setSymbolDetectedCallback { symbol in
      DispatchQueue.main.async {
        self.navigationItem.title = symbol
        self.textOutput.text = (self.textOutput.text ?? "") + symbol!
      }
    }
    
//    frameProcessor.setSignalDetectionEventCallback { detectedSignal in
//      DispatchQueue.main.async {
//        if detectedSignal {
//          // Detected signal switch on
//          self.navigationItem.title = "Signal!"
//        } else {
//          // Detected signal switch off
//          self.navigationItem.title = "No"
//        }
//      }
//    }
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
      view.layer.insertSublayer(preview, at: 0)
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
    let hudView = UIImageView(image: UIImage(named: "HUDImage"))
    hudView.contentMode = .center
    view.addSubview(hudView)
    hudView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([hudView.heightAnchor.constraint(equalTo: view.heightAnchor),
                                 hudView.widthAnchor.constraint(equalTo: view.widthAnchor),
                                 hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                 hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
  }
}
