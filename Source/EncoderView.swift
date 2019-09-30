//
//  EncoderView.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 27.09.19.
//  Copyright © 2019 nide. All rights reserved.
//

import SwiftUI

struct EncoderView: View {
  @State var message: String = "" //create State
  
  let encoder = FlashlightEncoder()
  
  var body: some View {
    VStack {
      ZStack(alignment: .topLeading) {
        Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 0.2)
        TextField("Enter Text here..", text: $message).lineLimit(nil)
      }.cornerRadius(10).padding()
      HStack {
        Button(action: {
          self.encoder.emitMorseMessage(self.message)
        }) {
          Text("Morse").frame(width: 150, height: 60, alignment: .center).background(Color.green).cornerRadius(10).foregroundColor(.white)
        }
        Spacer()
        Button(action: {
          self.encoder.cancelMorseEmission()
        }) {
          Text("Cancel").frame(width: 150, height: 60, alignment: .center).background(Color.red).cornerRadius(10).foregroundColor(.white)
        }
      }.padding([.bottom, .trailing, .leading])
    }.tabItem {
      VStack {
        Image("EncoderItem")
        Text("Encode")
      }
    }.background(Color.black.edgesIgnoringSafeArea(.all))
    .navigationBarTitle("")
    .navigationBarHidden(true)
  }
}

struct EncoderView_Previews: PreviewProvider {
  static var previews: some View {
    EncoderView()
  }
}
