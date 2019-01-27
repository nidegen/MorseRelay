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
  var textOutput = UITextView(frame: .zero)
  var resetOutputButton = UIButton(frame: .zero)
  var startStopButton = UIButton(frame: .zero)
  
  var decoderDebugSignal: UIView?
  
  let frameProcessor = FrameProcessor()
  var previewLayer: AVCaptureVideoPreviewLayer?
  
  var cameraManager: CameraManager!
  
  var currentText = ""
  var currentWord = ""
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    cameraManager = CameraManager(captureDelegate: frameProcessor)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    cameraManager = CameraManager(captureDelegate: frameProcessor)
    super.init(coder: aDecoder)
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
        
        self.currentText += " " + (word ?? "")
        self.currentWord = ""
        self.textOutput.text = self.currentText
      }
    }
    
    frameProcessor.setSymbolDetectedCallback { symbol in
      DispatchQueue.main.async {
        self.currentWord += symbol ?? ""
        self.textOutput.text = self.currentText + " " + self.currentWord
      }
    }
    
    frameProcessor.setSignalDetectionEventCallback { detectedSignal in
      DispatchQueue.main.async {
        if detectedSignal {
          // Detected signal switch on
          // self.navigationItem.title = "Signal!"
          self.decoderDebugSignal?.backgroundColor = .red
        } else {
          // Detected signal switch off
          // self.navigationItem.title = "No"
          self.decoderDebugSignal?.backgroundColor = .clear
        }
      }
    }
    
    cameraManager.setupCamera()
    
    let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.captureSession)
    previewLayer.frame = view.bounds
    previewLayer.backgroundColor = UIColor.black.cgColor
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.insertSublayer(previewLayer, at: 0)
  }
  
  @objc func clearOutput(_ sender: Any?) {
    frameProcessor.reset()
    textOutput.text = ""
    currentText = ""
    currentWord = ""
  }
  
  @objc func startDecoding(_ sender: UIButton) {
    sender.setTitle("Stop", for: .normal)
    sender.setTitleColor(.red, for: .normal)
    sender.removeTarget(self, action: #selector(startDecoding(_:)), for: .touchDown)
    sender.addTarget(self, action: #selector(stopDecoding(_:)), for: .touchDown)
    frameProcessor.startProcessing()
  }
  
  @objc func stopDecoding(_ sender: UIButton) {
    sender.setTitle("Start", for: .normal)
    sender.setTitleColor(.green, for: .normal)
    sender.removeTarget(self, action: #selector(stopDecoding(_:)), for: .touchDown)
    sender.addTarget(self, action: #selector(startDecoding(_:)), for: .touchDown)
    frameProcessor.stopProcessing()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    previewLayer?.bounds = view.frame
  }
  
  // MARK: - Rotation
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait]
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
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    view.addSubview(blurView)
    blurView.clipsToBounds = true
    blurView.layer.cornerRadius = 5
    
    blurView.translatesAutoresizingMaskIntoConstraints = false
    blurView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -10).isActive = true
    blurView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
    blurView.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.95).isActive = true
    blurView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    
    textOutput.backgroundColor = .clear
    textOutput.textColor = .lightText
    textOutput.textAlignment = .justified
    textOutput.font = UIFont.systemFont(ofSize: 18)
    textOutput.isEditable = false
    textOutput.isScrollEnabled = true
    
    blurView.contentView.addSubview(textOutput)
    textOutput.translatesAutoresizingMaskIntoConstraints = false
    textOutput.heightAnchor.constraint(equalTo: blurView.heightAnchor).isActive = true
    textOutput.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
    textOutput.leftAnchor.constraint(equalTo: blurView.leftAnchor).isActive = true
    
    resetOutputButton.backgroundColor = .clear
    resetOutputButton.setTitle("Clear", for: .normal)
    resetOutputButton.addTarget(self, action: #selector(clearOutput), for: .touchDown)
    blurView.contentView.addSubview(resetOutputButton)
    resetOutputButton.translatesAutoresizingMaskIntoConstraints = false
    resetOutputButton.heightAnchor.constraint(equalTo: blurView.heightAnchor, multiplier: 0.5).isActive = true
    resetOutputButton.topAnchor.constraint(equalTo: blurView.topAnchor).isActive = true
    resetOutputButton.leftAnchor.constraint(equalTo: textOutput.rightAnchor).isActive = true
    resetOutputButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    resetOutputButton.rightAnchor.constraint(equalTo: blurView.rightAnchor).isActive = true
    
    
    
    startStopButton.backgroundColor = .clear
    startStopButton.setTitle("Start", for: .normal)
    startStopButton.setTitleColor(.green, for: .normal)
    startStopButton.addTarget(self, action: #selector(startDecoding), for: .touchDown)
    blurView.contentView.addSubview(startStopButton)
    startStopButton.translatesAutoresizingMaskIntoConstraints = false
    startStopButton.heightAnchor.constraint(equalTo: blurView.heightAnchor, multiplier: 0.5).isActive = true
    startStopButton.bottomAnchor.constraint(equalTo: blurView.bottomAnchor).isActive = true
    startStopButton.leftAnchor.constraint(equalTo: textOutput.rightAnchor).isActive = true
    startStopButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    startStopButton.rightAnchor.constraint(equalTo: blurView.rightAnchor).isActive = true
    
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
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent //.default for black style
  }
}
