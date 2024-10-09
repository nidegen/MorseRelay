import Foundation
import AVFoundation
import CoreMedia
import CoreVideo
import UIKit
import MorseVision

@Observable
class SignalProcessor {
  #if DEBUG
  var parsedMessage: String = "SOS SINKING"
  #else
  var parsedMessage: String = ""
  #endif
  var signal: [MorseSignal] = []
  var currentBrightness: Float = 0.0
  var detectedSignalIsOn: Bool = false
  private var signalChangedCallback: ((Bool) -> Void)?
  private var previousFrameHadFlash = false
  let stepDetector = StepDetector()
  let start = Date()
  var lastTime: Date?

  var isProcessing = false {
    didSet {
      if isProcessing {
        signal = []
        parsedMessage = ""
      }
    }
  }

  func processSampleBuffer(output: AVCaptureOutput, buffer: CMSampleBuffer, connection: AVCaptureConnection) {
    let brightness = ImageProcessing.read(buffer)
    currentBrightness = brightness

    if let isOn = stepDetector.processNewSignal(signal: brightness) {

      if isProcessing {
        signal.append(
          MorseSignal(
            duration: -(lastTime?.timeIntervalSinceNow ?? 0),
            isOn: detectedSignalIsOn
          )
        )
        self.detectedSignalIsOn = isOn
        lastTime = .now

        let elements = signal.compactMap {
          Coder.decode(signal: $0)
        }
        parsedMessage = Coder.decode(elements: elements)
      }
    }
  }

  var signals: AsyncStream<Bool> {
    AsyncStream { [weak self] continuation in
      self?.signalChangedCallback = { isOn in
        continuation.yield(isOn)
      }
    }
  }
}
