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
  
  // MARK: - UI Properties
  var textOutput: UILabel!
  var resetOutputButton: UIButton!
  
  var decoderDebugSignal: UIView?
  
  // MARK: - Camera/Processing Properties
  
  lazy var captureSession: AVCaptureSession = {
    let session = AVCaptureSession()
    session.sessionPreset = .high
    return session
  }()
  
  let frameProcessor = FrameProcessor()
  var previewLayer: AVCaptureVideoPreviewLayer?
  let sampleBufferQueue = DispatchQueue.global(qos: .userInteractive)
  
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
  
  // MARK: - View Lifecycle
  
  @objc func clearOutput() {
    textOutput.text = ""
  }
  
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
        self.textOutput.text = (self.textOutput.text ?? "") + " "// + word!
      }
    }
    
    frameProcessor.setSymbolDetectedCallback { symbol in
      DispatchQueue.main.async {
        self.navigationItem.title = symbol
        self.textOutput.text = (self.textOutput.text ?? "") + symbol!
      }
    }
    
    frameProcessor.setSignalDetectionEventCallback { detectedSignal in
      DispatchQueue.main.async {
        if detectedSignal {
          self.decoderDebugSignal?.backgroundColor = .yellow
        } else {
          // Detected signal switch off
          self.decoderDebugSignal?.backgroundColor = .clear
        }
      }
    }
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
    blurView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20).isActive = true
    blurView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    blurView.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.9).isActive = true
    
    textOutput = UILabel(frame: .zero)
    textOutput.backgroundColor = .clear
    textOutput.textColor = .lightText
    textOutput.textAlignment = .center
    textOutput.font = UIFont.systemFont(ofSize: 24)
    
    blurView.contentView.addSubview(textOutput)
    textOutput.translatesAutoresizingMaskIntoConstraints = false
    textOutput.heightAnchor.constraint(equalTo: blurView.heightAnchor).isActive = true
    textOutput.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
    textOutput.leftAnchor.constraint(equalTo: blurView.leftAnchor).isActive = true
    
    resetOutputButton = UIButton(frame: .zero)
    resetOutputButton.backgroundColor = .clear
    resetOutputButton.setTitle("Clear", for: .normal)
    resetOutputButton.addTarget(self, action: #selector(clearOutput), for: .touchDown)
    blurView.contentView.addSubview(resetOutputButton)
    resetOutputButton.translatesAutoresizingMaskIntoConstraints = false
    resetOutputButton.heightAnchor.constraint(equalTo: blurView.heightAnchor).isActive = true
    resetOutputButton.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
    resetOutputButton.leftAnchor.constraint(equalTo: textOutput.rightAnchor).isActive = true
    resetOutputButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    resetOutputButton.rightAnchor.constraint(equalTo: blurView.rightAnchor).isActive = true
    
    #if DEBUG
    let decoderDebugSignal = UIView(frame: .zero)
    view.addSubview(decoderDebugSignal)
    self.decoderDebugSignal = decoderDebugSignal
    decoderDebugSignal.backgroundColor = .clear
    decoderDebugSignal.translatesAutoresizingMaskIntoConstraints = false
    decoderDebugSignal.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -30).isActive = true
    decoderDebugSignal.topAnchor.constraint(equalTo: margins.topAnchor, constant: 30).isActive = true
    decoderDebugSignal.widthAnchor.constraint(equalToConstant: 20).isActive = true
    decoderDebugSignal.heightAnchor.constraint(equalToConstant: 20).isActive = true
    decoderDebugSignal.layer.cornerRadius = 5
    decoderDebugSignal.layer.borderColor = UIColor.black.cgColor
    decoderDebugSignal.layer.borderWidth = 3
    decoderDebugSignal.layer.masksToBounds = true
    #endif
  }
}
