class StepDetector {
  var previousSignalWasOn: Bool = false
  var previousSignal: Float = 1;

  func processNewSignal(signal: Float) -> Bool? {
    let delta = signal / (previousSignal + 0.001)
    previousSignal = signal
    if (!previousSignalWasOn && delta > 1.3) {
      previousSignalWasOn = true
      return true
    } else if (previousSignalWasOn && delta < 0.9) {
      previousSignalWasOn = false;
      return false
    }
    return nil
  }
}
