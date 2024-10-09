//
//  CameraView.swift
//  CameraKit
//
//  Created by Nicolas Degen on 21.06.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import SwiftUI

import AVKit

public struct CameraView: View {
  @ObservedObject
  public var cameraManager: CameraManager

  public init(cameraManager: CameraManager) {
    self.cameraManager = cameraManager
  }

  public init() {
    self.cameraManager = CameraManager()
  }
  @State var animate = false

  public var body: some View {
    Group {
      if cameraManager.cameraAccessGranted {
        CameraPreviewWrapper(cameraManager: cameraManager)
          .onAppear {
            Task {
              self.cameraManager.startCamera()
            }
          }
          .overlay(alignment: .center) {
            Image(systemName: "viewfinder")
              .fontWeight(.ultraLight)
              .font(.largeTitle)
              .foregroundStyle(.yellow)
              .symbolEffect(.bounce, value: animate)
              .onAppear {
                animate.toggle()
              }
          }
      } else {
        ContentUnavailableView {
          Label("Camera Access", systemImage: "camera")
        } description: {
          Text("In order to read morse code, you need to grant camera access.")
        } actions: {
          Button("Grant Access") {
            Task { await self.cameraManager.requestCameraAccess() }
          }
          .buttonStyle(.bordered)
        }
      }
    }
  }

  public func onPhotoCaptured(perform action: ((AVCapturePhotoOutput, AVCapturePhoto, Error?) -> Void)? = nil)
    -> CameraView
  {
    self.cameraManager.onDidCapturePhoto = action
    return self
  }

  public func onQRStringDetected(perform action: ((String) -> Void)? = nil) -> CameraView {
    self.cameraManager.onDetectedQRString = action
    return self
  }
}

struct CameraView_Previews: PreviewProvider {
  static var previews: some View {
    CameraView(cameraManager: CameraManager())
  }
}
