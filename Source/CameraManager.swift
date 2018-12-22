//
//  CameraManager.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 29.08.18.
//  Copyright © 2018 nide. All rights reserved.
//

import AVFoundation
import CoreImage

class CameraManager {
  // MARK: - Properties
  
  lazy var captureSession: AVCaptureSession = {
    let session = AVCaptureSession()
    session.sessionPreset = .high
    return session
  }()
  
  let sampleBufferQueue = DispatchQueue.global(qos: .userInteractive)
  let captureDelegate: AVCaptureVideoDataOutputSampleBufferDelegate!
  
  init(captureDelegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
    self.captureDelegate = captureDelegate
  }
  
  func startCamera() {
    captureSession.startRunning()
  }
  
  func stopCamera() {
    captureSession.stopRunning()
  }
  
  func setupCamera() {
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
  
  // MARK: - Camera Capture
  
  private func findCamera() -> AVCaptureDevice? {
    #if os(iOS)
    let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera]
    let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .back)
    return discovery.devices.first
    #elseif os(macOS)
    return AVCaptureDevice.default(for: .video)
    #else
    print("OMG, it's that mythical new Apple product!!!")
    #endif
  }
  
  func setupCaptureSession() {
    guard captureSession.inputs.isEmpty else { return }
    guard let camera = findCamera() else {
      print("No camera found")
      return
    }
    
    do {
      let cameraInput = try AVCaptureDeviceInput(device: camera)
      captureSession.addInput(cameraInput)
      
      let output = AVCaptureVideoDataOutput()
      output.alwaysDiscardsLateVideoFrames = true
      output.setSampleBufferDelegate(captureDelegate, queue: sampleBufferQueue)
      
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
}
