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
  
  let frameProcessor = FrameProcessor()
  var previewLayer: AVCaptureVideoPreviewLayer?
  let sampleBufferQueue = DispatchQueue.global(qos: .userInteractive)
  
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
    let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera]
    let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .back)
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
      
      previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      
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
}
