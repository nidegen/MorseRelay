import Foundation

struct MorseSignal {
  let duration: TimeInterval
  let isOn: Bool
}

struct MorseConfig {
  let ditDuration: Double = 0.2
  let dahDuration: Double = 0.6
  let signalGap: Double = 0.2
  let letterGap: Double = 0.6
  let letterGapThreshold: Double = 0.35
  let wordGapThreshold: Double = 1.0
  let wordGapDuration: Double = 1.4

  var minDitDuration: Double {
    ditDuration / 2
  }
}
