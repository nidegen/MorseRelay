//
//  DecoderViewController.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 11.07.18.
//  Copyright © 2018 nide. All rights reserved.
//
import UIKit
import AVFoundation
import CoreImage

class DecoderViewController: UIViewController {
  var textOutput: UILabel!
  
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    frameProcessor.reset()
  }
  
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
      preview.videoGravity = .resizeAspectFill
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
    
    let margins = view.layoutMarginsGuide
    navigationController?.isNavigationBarHidden = true
    
    let hudView = UIImageView(image: UIImage(named: "HUDImage"))
    hudView.contentMode = .center
    view.addSubview(hudView)
    hudView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([hudView.heightAnchor.constraint(equalTo: view.heightAnchor),
                                 hudView.widthAnchor.constraint(equalTo: view.widthAnchor),
                                 hudView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                 hudView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    
    textOutput = UILabel(frame: .zero)

    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    view.addSubview(blurView)
    blurView.clipsToBounds = true
    blurView.layer.cornerRadius = 5
    
    blurView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([blurView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20),
                                 blurView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
                                 blurView.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
                                 blurView.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.7)])
    
    textOutput = UILabel(frame: .zero)
    textOutput.backgroundColor = .clear
    textOutput.textColor = .lightText
    textOutput.textAlignment = .center
    textOutput.font = UIFont.systemFont(ofSize: 24)
    
    blurView.contentView.addSubview(textOutput)
    textOutput.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([textOutput.heightAnchor.constraint(equalTo: blurView.heightAnchor),
                                 textOutput.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
                                 textOutput.centerYAnchor.constraint(equalTo: blurView.centerYAnchor),
                                 textOutput.widthAnchor.constraint(equalTo: blurView.widthAnchor)])
  }
}
