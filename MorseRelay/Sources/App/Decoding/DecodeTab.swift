import SwiftUI
import CameraKit
import MorseVision

struct DecodeTab: View {
  @State var camera = CameraManager()
  @State var processor = SignalProcessor()

  public var body: some View {
    ZStack {
      ScrollView {
        Spacer()
          .frame(height: 111111111)
      }

      CameraView(cameraManager: camera)
        .onAppear {
          camera.onDidCaptureSampleBuffer = processor.processSampleBuffer(output:buffer:connection:)
        }
        .overlay(alignment: .topTrailing) {
          FlashLight(isOn: processor.detectedSignalIsOn)
            .padding()
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding()
        }
        .overlay(alignment: .bottom) {
          HStack {
            VStack(alignment: .leading) {
              HStack {
                Text("Output")
                  .foregroundStyle(.secondary)
                  .font(.caption2)
                if processor.isProcessing {
                  ProgressView()
                    .controlSize(.mini)
                }

                Spacer()

                if processor.parsedMessage != "" {
                  ShareLink(item: processor.parsedMessage)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .controlSize(.mini)

                  Button {
                    processor.parsedMessage = ""
                    processor.signal = []
                  } label: {
                    Text("Clear")
                  }
                  .buttonStyle(.bordered)
                  .buttonBorderShape(.capsule)
                  .controlSize(.mini)
                }
              }

              ScrollView {
                Text(processor.parsedMessage)
              }
            }

            Spacer()

            RecordButton(isRecording: $processor.isProcessing) {
            } stopAction: {
            }
            .frame(width: 36, height: 36)
          }
          .frame(maxWidth: .infinity, maxHeight: 96)
          .padding()
          .background(.thinMaterial)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .padding()
        }
    }
  }
}

#Preview {
  DecodeTab()
}
