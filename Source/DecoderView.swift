//
//  DecoderView.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 03.02.20.
//  Copyright © 2020 nide. All rights reserved.
//

import SwiftUI
import SwiftUIBlurView

import CameraKit

struct DecoderView: View {
  @Binding var decodedText: String
  @Binding var isProcessing: Bool
  @Binding var currentSignalState: Bool
  
  let cameraManager: CameraManager
  
  var body: some View {
    ZStack {
      CameraView(cameraManager: cameraManager).edgesIgnoringSafeArea(.all)
      Image("HUDImage").edgesIgnoringSafeArea(.all)
      VStack {
        HStack {
          ZStack {
            BlurView(style: .systemUltraThinMaterial)
            Text(decodedText).multilineTextAlignment(.leading)
          }
          .frame(height: 90)
          .cornerRadius(10)
        }
        Spacer()
        Button(action: {
          self.isProcessing.toggle()
        }) {
          Group {
            if self.isProcessing {
              Text("Stop")
                .foregroundColor(.white)
                .frame(width: 77, height: 77)
                .background(Color.red)
                .clipShape(Circle())
            } else {
              Text("Start")
                .foregroundColor(.white)
                .frame(width: 77, height: 77)
                .background(Color.green)
                .clipShape(Circle())
            }
          }
        }
      }
      .padding()
      .onAppear {
        self.cameraManager.startCamera()
      }
      .onDisappear {
        self.cameraManager.stopCamera()
      }
    }
    .tabItem {
      VStack {
        Image("DecoderItem")
        Text("Decoder")
      }
    }
  }
}

struct DecoderView_Previews: PreviewProvider {
  @State static var signal = false
  @State static var isProcessing = true
  @State static var text = "SOSasdfas df\nasdfsdfsdfsdf"
  static var previews: some View {
    DecoderView(decodedText: $text, isProcessing: $isProcessing, currentSignalState: $signal, cameraManager: CameraManager())
  }
}
