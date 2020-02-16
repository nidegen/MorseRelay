//
//  EncoderView.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 27.09.19.
//  Copyright © 2019 nide. All rights reserved.
//

import SwiftUI
import MultilineTextField

struct EncoderView: View {
  @State var message: String = "" //create State
  
  let encoder = FlashlightEncoder()
  
  var body: some View {
    VStack {
      ZStack(alignment: .topLeading) {
        Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 0.2)
        MultilineTextField(placeholderText: "Enter Text here..", text: $message).lineLimit(nil).padding()
      }.cornerRadius(10).padding()
      HStack {
        morseButton
        Spacer()
        cancelButton
      }.padding([.bottom, .trailing, .leading])
    }
    .tabItem {
      VStack {
        Image("EncoderItem")
        Text("Encode")
      }
    }
    .background(Image("Background").edgesIgnoringSafeArea(.all))
    .navigationBarTitle("")
    .navigationBarHidden(true)
  }
  
  var morseButton: some View {
    Button(action: {
      self.encoder.emitMorseMessage(self.message)
    }) {
      Text("Morse").frame(width: 150, height: 60, alignment: .center).background(Color.green).cornerRadius(10).foregroundColor(.white)
    }
  }
  
  var cancelButton: some View {
    Button(action: {
      self.encoder.cancelMorseEmission()
    }) {
      Text("Cancel").frame(width: 150, height: 60, alignment: .center).background(Color.red).cornerRadius(10).foregroundColor(.white)
    }
  }
}

struct EncoderView_Previews: PreviewProvider {
  static var previews: some View {
    EncoderView()
  }
}
