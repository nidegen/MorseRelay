import AVFoundation
import Foundation
import SwiftUI

struct SentMessage: Identifiable {
  let id: UUID = UUID()
  let text: String
  let date: Date
}

@MainActor
@Observable
class MorseEncoder {
  #if DEBUG
  var sentMessages: [SentMessage] = [
    .init(
      text: "SOS WE ARE SINKING SOS",
      date: .now
    )
  ]
  #else
  var sentMessages: [SentMessage] = []
  #endif
  var text: String = ""
  var flashLightIsOn = false
  var isSendingMessage = false

  private let device: AVCaptureDevice?

  init() {
    self.device = AVCaptureDevice.default(for: .video)
  }

  func emit() {
    Task {
      await self.emitMorseCode(for: text)
      text = ""
    }
  }

  func emitMorseCode(for message: String) async {
    defer {
      isSendingMessage = false
    }
    isSendingMessage = true

    device?.torchMode = .off
    flashLightIsOn = false

    let signal = Coder.encode(elements: Coder.encode(message: message))

    var output: [MorseSignal] = []
    var last = Date()
    var lastState: Bool?

    for await newState in Coder.encode(signal: signal) {
      let now = Date.now
      if let lastState {
        output.append(MorseSignal(duration: -last.timeIntervalSince(now), isOn: lastState))
      }
      lastState = newState
      last = now
      flashLightIsOn = newState
      device?.torchMode = newState ? .on : .off
    }

    device?.torchMode = .off
    flashLightIsOn = false
    device?.unlockForConfiguration()
    withAnimation {
      sentMessages.append(SentMessage(text: message, date: .now))
    }
  }

  private func toggleFlash(duration: UInt64) async {
    flashLightIsOn = true
    device?.torchMode = .on
    try? await Task.sleep(nanoseconds: duration)
    device?.torchMode = .off
    flashLightIsOn = false
  }
}
