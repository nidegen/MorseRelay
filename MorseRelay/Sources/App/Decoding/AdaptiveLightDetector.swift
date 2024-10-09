class AdaptiveLightDetector {
  private var recentBrightness: [Float] = []
  private let windowSize: Int
  private let changeThreshold: Float

  init(windowSize: Int = 10, changeThreshold: Float = 0.2) {
    self.windowSize = windowSize
    self.changeThreshold = changeThreshold
  }

  func isLightOn(currentBrightness: Float) -> Bool {
    // Add the current brightness to our recent measurements
    recentBrightness.append(currentBrightness)

    // Keep only the most recent measurements
    if recentBrightness.count > windowSize {
      recentBrightness.removeFirst()
    }

    // If we don't have enough data yet, assume the light is off
    guard recentBrightness.count == windowSize else {
      return false
    }

    // Calculate the average brightness
    let averageBrightness = recentBrightness.reduce(0, +) / Float(recentBrightness.count)

    // Determine if the current brightness is significantly higher than the average
    return currentBrightness > averageBrightness * (1 + changeThreshold)
  }
}
