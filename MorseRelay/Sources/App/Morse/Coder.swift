import Foundation
enum Coder {
  static func encode(
    elements: [MorseElement],
    config: MorseConfig = .init()
  ) -> [MorseSignal] {
    var signal: [MorseSignal] = []
    for element in elements {
      switch element {
      case .wordGap:
        signal.append(
          MorseSignal(
            duration: config.wordGapDuration,
            isOn: false
          )
        )
      case .dah:
        if signal.last?.isOn == true {
          signal.append(
            MorseSignal(
              duration: config.signalGap,
              isOn: false
            )
          )
        }
        signal.append(
          MorseSignal(
            duration: config.dahDuration,
            isOn: true
          )
        )
      case .dit:
        if signal.last?.isOn == true {
          signal.append(
            MorseSignal(
              duration: config.signalGap,
              isOn: false
            )
          )
        }
        signal.append(
          MorseSignal(
            duration: config.ditDuration,
            isOn: true
          )
        )
      case .letterGap:
        signal.append(
          MorseSignal(
            duration: config.letterGap,
            isOn: false
          )
        )
      }
    }
    return signal
  }

  static func encode(message: String) -> [MorseElement] {
    var elements = [MorseElement]()

    for char in message.uppercased() {
      switch char {
      case " ":
        elements.append(.wordGap)
      default:
        if let morse = Mapping.characterToMorse[char] {
          let e: [MorseElement] = morse.map {
            switch $0 {
            case ".":
              .dit
            case "-":
              .dah
            default:
              .dit
            }
          }
          if elements.last == .dah || elements.last == .dit {
            elements.append(.letterGap)
          }
          elements += e
        }
      }
    }
    return elements
  }

  static func encode(
    signal: [MorseSignal]
  ) -> AsyncStream<Bool> {
    AsyncStream<Bool> { continuation in
      Task {
        for signal in signal {
          continuation.yield(signal.isOn)
          try? await Task.sleep(for: .seconds(signal.duration))
        }
        continuation.yield(false)
        try? await Task.sleep(for: .seconds(0.2))
        continuation.finish()
      }
    }
  }

  static func decode(inputStream: AsyncStream<Bool>) -> AsyncStream<MorseSignal> {
    AsyncStream<MorseSignal> { continuation in
      Task {
        var lastTime: Date?
        var lastInput: Bool?
        for await input in inputStream {
          if let lastInput, let lastTime, lastInput != input {
            continuation.yield(MorseSignal(duration: -lastTime.timeIntervalSinceNow, isOn: lastInput))
          }
          if (lastInput != input) {
            lastTime = Date()
          }
          lastInput = input
        }
        if lastInput != nil, let lastTime = lastTime {
          continuation.yield(MorseSignal(duration: -lastTime.timeIntervalSinceNow, isOn: false))
        }
        continuation.finish()
      }
    }
  }

  static func decode(
    signal: MorseSignal,
    config: MorseConfig = .init()
  ) -> MorseElement? {
    if signal.isOn {
      if signal.duration <= config.minDitDuration {
        return nil
      } else if signal.duration <= (config.ditDuration + config.dahDuration) / 2 {
        return .dit
      } else {
        return .dah
      }
    }

    if !signal.isOn {
      if signal.duration > config.wordGapThreshold {
        return .wordGap
      } else if signal.duration > config.letterGapThreshold {
        return .letterGap
      }
    }
    return nil
  }

  static func decode(elements: [MorseElement]) -> String {
    var currentSequence = ""
    var decodedMessage = ""

    for element in elements {
      switch element {
      case .dit:
        currentSequence += "."
      case .dah:
        currentSequence += "-"
      case .letterGap:
        if let letter = Mapping.morseToCharacter[currentSequence] {
          decodedMessage += String(letter)
        }
        currentSequence = ""
      case .wordGap:
        if let letter = Mapping.morseToCharacter[currentSequence] {
          decodedMessage += String(letter)
        }
        decodedMessage += " "
        currentSequence = ""
      }
    }

    // Add the last letter if there's an unprocessed sequence
    if let letter = Mapping.morseToCharacter[currentSequence] {
      decodedMessage += String(letter)
    }
    return decodedMessage
  }
}
