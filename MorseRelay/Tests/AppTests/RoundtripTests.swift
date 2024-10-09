@testable import App
import Testing

struct RoundtripTests {
  @Test func elementsToSignalCoding() async {
    let elements: [MorseElement] = [.dit, .dit, .dit, .letterGap, .dah, .dah, .dah, .letterGap, .dit, .dit, .dit]

    let signal = Coder.encode(elements: elements)
    let decoded = signal.compactMap { Coder.decode(signal: $0) }

    #expect(decoded == elements)
  }

  @Test func messageToElementsCoding() async {
    let message = "SOS SINKING HELP"
    let elements = Coder.encode(message: message)
    let decoded = Coder.decode(elements: elements)

    #expect(decoded == message)
  }

  @Test func roundTip() async {
    let message = "S T"
    let elements = Coder.encode(message: message)
    let expectedElements: [MorseElement] = [.dit, .dit, .dit, .wordGap, .dah]

    #expect(elements == expectedElements)

    let encodedSignal = Coder.encode(elements: elements)
    let decodedElements = encodedSignal.compactMap { Coder.decode(signal: $0) }

    #expect(decodedElements == elements)

    let decoded = Coder.decode(elements: decodedElements)

    #expect(decoded == message)
  }
}
