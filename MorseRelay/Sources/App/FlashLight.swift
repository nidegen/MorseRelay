import SwiftUI

struct FlashLight: View {
  let isOn: Bool

  var body: some View {
    if isOn {
      Image(systemName: "sun.max.fill")
    } else {
      Image(systemName: "sun.max")
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  FlashLight(isOn: true)
  FlashLight(isOn: false)
}
