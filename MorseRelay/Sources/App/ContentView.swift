import SwiftUI

public struct ContentView: View {
  @AppStorage("tabSelection")
  var selection = "encoder"

  public init() {}

  public var body: some View {
    TabView(selection: $selection) {
      Tab(value: "encoder") {
        EncodeTab()
      } label: {
        Label("Encode", systemImage: "rays")
      }
      Tab(value: "decoder") {
        DecodeTab()
      } label: {
        Label("Decode", systemImage: "text.viewfinder")
      }
    }
  }
}

#Preview {
  ContentView()
}
