import SwiftUI

struct EncodeTab: View {
  @State var encoder = MorseEncoder()

  var body: some View {
    NavigationStack {
      VStack {
        if encoder.sentMessages.isEmpty {
          ContentUnavailableView("Send a message", systemImage: "flashlight.off.circle")
        } else {
          Form {
            Section {
              List(encoder.sentMessages) { message in
                Menu {
                  Button("Use Text") {
                    encoder.text = message.text
                  }
                } label: {
                  LabeledContent {
                    Text(message.text)
                  } label: {
                    Text(message.date, style: .time)
                  }
                }
              }
            } header: {
              Text("History")
            }
          }
        }
      }
      .safeAreaInset(edge: .bottom) {
        HStack {
          TextField("Enter message to send", text: $encoder.text)
            .disableAutocorrection(true)
            .textFieldStyle(.roundedBorder)
            .textInputAutocapitalization(.characters)
            .disabled(encoder.isSendingMessage)

          if encoder.isSendingMessage {
            ProgressView()
          } else {
            Button("Send") {
              encoder.emit()
            }
            .disabled(encoder.text == "")
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
          }
        }
        .padding()
      }
      .toolbar {
        if encoder.isSendingMessage {
          ToolbarItem(placement: .topBarTrailing) {
            FlashLight(isOn: encoder.flashLightIsOn)
          }
        }
      }
      #if targetEnvironment(simulator)
      .overlay {
        FlashLight(isOn: encoder.flashLightIsOn).scaleEffect(5).background(.black)
      }
      #endif
      .navigationTitle("Send")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  EncodeTab()
}
