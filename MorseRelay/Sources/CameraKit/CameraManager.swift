//
//  CameraManager.swift
//  CameraKit
//
//  Created by Nicolas Degen on 24.10.18.
//  Copyright © 2018 Nicolas Degen. All rights reserved.
//

@preconcurrency import AVFoundation
import CoreImage
import UIKit

public class CameraManager: NSObject, ObservableObject {
  @Published
  var cameraAccessGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized

  lazy var captureSession: AVCaptureSession = {
    let session = AVCaptureSession()
    session.sessionPreset = .high
    return session
  }()

  let cameraQueue = DispatchQueue(label: "video.preview.session")
  public let photoOutput = AVCapturePhotoOutput()

  public var sampleBufferOutputDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
  public var metaDataOutputDelegate: AVCaptureMetadataOutputObjectsDelegate!
  public var photoCaptureDelegate: AVCapturePhotoCaptureDelegate?

  public override init() {
    super.init()
    metaDataOutputDelegate = self
    photoCaptureDelegate = self
    sampleBufferOutputDelegate = self

    if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
      setupCaptureSession()
    }
  }

  public var onDidCapturePhoto: ((AVCapturePhotoOutput, AVCapturePhoto, Error?) -> ())?

  public var onDetectedQRString: ((String) -> ())?

  public typealias SampleBufferCapture = (AVCaptureOutput, CMSampleBuffer, AVCaptureConnection) -> ()
  public var onDidCaptureSampleBuffer: SampleBufferCapture?

  var lastDetectedQRString = ""

  @MainActor
  public func requestCameraAccess() async {
    let granted = await AVCaptureDevice.requestAccess(for: .video)
    self.cameraAccessGranted = granted
    self.setupCaptureSession()
  }

  public func startCamera() {
    #if targetEnvironment(simulator)
    return
    #endif
    if !captureSession.isRunning {
      cameraQueue.async { [captureSession] in
        captureSession.startRunning()
      }
    }
  }

  public func stopCamera() {
    if captureSession.isRunning {
      captureSession.stopRunning()
    }
  }

  #if os(iOS)
  @MainActor
  public func addPreviewLayer(view: UIView) {
    if captureSession.inputs.isEmpty {
      return
    }
    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.bounds
    previewLayer.backgroundColor = UIColor.black.cgColor
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.insertSublayer(previewLayer, at: 0)
  }
  #endif

  // MARK: - Camera Capture

  private func findCamera() -> AVCaptureDevice? {
    #if os(iOS)
    let deviceTypes: [AVCaptureDevice.DeviceType] = [
      .builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera,
    ]
    let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .back)
    return discovery.devices.first
    #elseif os(macOS)
    return AVCaptureDevice.default(for: .video)
    #else
    print("OMG, it's that mythical new Apple product!!!")
    #endif
  }

  public func capturePhoto() {
    guard let delegate = self.photoCaptureDelegate else { return }
    let photoSettings = AVCapturePhotoSettings()
    photoSettings.isHighResolutionPhotoEnabled = true
    photoSettings.flashMode = .auto

    if let firstAvailablePreviewPhotoPixelFormatTypes = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
      photoSettings.previewPhotoFormat = [
        kCVPixelBufferPixelFormatTypeKey as String: firstAvailablePreviewPhotoPixelFormatTypes
      ]
    }

    self.photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
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

      if let sampleBufferOutputDelegate = self.sampleBufferOutputDelegate {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(sampleBufferOutputDelegate, queue: cameraQueue)

        for pixelType in output.availableVideoPixelFormatTypes {
          if pixelType == kCVPixelFormatType_32BGRA {

          }
          if (pixelType == kCVPixelFormatType_32BGRA) || (pixelType == kCVPixelFormatType_32RGBA) {
            var videoSettings = [String: Any]()
            videoSettings[kCVPixelBufferPixelFormatTypeKey as String] = pixelType
            output.videoSettings = videoSettings
            break
          }
        }
        captureSession.addOutput(output)
      }

      let metaDataOutput = AVCaptureMetadataOutput()
      captureSession.addOutput(metaDataOutput)
      metaDataOutput.setMetadataObjectsDelegate(metaDataOutputDelegate, queue: cameraQueue)
      metaDataOutput.metadataObjectTypes = metaDataOutput.availableMetadataObjectTypes

      // Add photo output.
      if captureSession.canAddOutput(photoOutput) {
        captureSession.addOutput(photoOutput)

        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
      } else {
        print("Could not add photo output to the session")
      }
      captureSession.commitConfiguration()
    } catch let error {
      print("Error creating capture session: \(error)")
      return
    }
  }

  @discardableResult public func switchCamera() -> AVCaptureDevice.Position {
    captureSession.beginConfiguration()

    // Remove existing input
    guard let currentCameraInput: AVCaptureInput = captureSession.inputs.first else {
      return AVCaptureDevice.Position.unspecified
    }

    captureSession.removeInput(currentCameraInput)

    // Get new input
    var newCamera: AVCaptureDevice! = nil
    if let input = currentCameraInput as? AVCaptureDeviceInput {
      if (input.device.position == .back) {
        newCamera = cameraWithPosition(position: .front)
      } else {
        newCamera = cameraWithPosition(position: .back)
      }
    }

    // Add input to session
    var err: NSError?
    var newVideoInput: AVCaptureDeviceInput!
    do {
      newVideoInput = try AVCaptureDeviceInput(device: newCamera)
    } catch let err1 as NSError {
      err = err1
      newVideoInput = nil
    }

    if newVideoInput == nil, let error = err {
      print("Error creating capture device input: \(error.localizedDescription)")
    } else {
      captureSession.addInput(newVideoInput)
    }

    captureSession.commitConfiguration()
    return newVideoInput.device.position
  }

  func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
    let discoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInWideAngleCamera],
      mediaType: AVMediaType.video,
      position: .unspecified
    )
    for device in discoverySession.devices {
      if device.position == position {
        return device
      }
    }

    return nil
  }
}

extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
  public func metadataOutput(
    _ output: AVCaptureMetadataOutput,
    didOutput metadataObjects: [AVMetadataObject],
    from connection: AVCaptureConnection
  ) {
    if metadataObjects.count == 0 {
      return
    }

    // Get the metadata object.
    guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
      return
    }
    if metadataObj.type == AVMetadataObject.ObjectType.qr {
      let qrString = metadataObj.stringValue ?? ""

      if qrString != lastDetectedQRString {
        self.onDetectedQRString?(qrString)
        lastDetectedQRString = qrString
      }
    }
  }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
  public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
  {
    self.onDidCapturePhoto?(output, photo, error)
  }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  public func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    onDidCaptureSampleBuffer?(output, sampleBuffer, connection)
  }
}
