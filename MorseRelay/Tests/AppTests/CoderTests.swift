@testable import App
import Foundation
import Testing

struct CoderTests {
  let weedSignal: [MorseSignal] = [
    MorseSignal(duration: 0.26713907718658602, isOn: true),
    MorseSignal(duration: 0.16625499725341797, isOn: false),
    MorseSignal(duration: 0.6658499240875244, isOn: true),
    MorseSignal(duration: 0.16401207447052002, isOn: false),
    MorseSignal(duration: 0.7035800218582153, isOn: true),
    MorseSignal(duration: 0.8000259399414062, isOn: false),
    MorseSignal(duration: 0.23424196243286133, isOn: true),
    MorseSignal(duration: 0.8328781127929688, isOn: false),
    MorseSignal(duration: 0.23363494873046875, isOn: true),
    MorseSignal(duration: 0.8327610492706299, isOn: false),
    MorseSignal(duration: 0.6664459705352783, isOn: true),
    MorseSignal(duration: 0.16703796386718750, isOn: false),
    MorseSignal(duration: 0.26706397533416748, isOn: true),
    MorseSignal(duration: 0.16638207435607910, isOn: false),
    MorseSignal(duration: 0.23366701602935791, isOn: true),
    MorseSignal(duration: 3.03332090377807617, isOn: false),
    MorseSignal(duration: 0.02959907054901123, isOn: true),
    MorseSignal(duration: 0.03785300254821777, isOn: false),
    MorseSignal(duration: 1.36580395698547363, isOn: true),
    MorseSignal(duration: 0.13313698768615723, isOn: false),
  ]

  let sssSignal: [MorseSignal] = [
    MorseSignal(duration: 0.0, isOn: true),
    MorseSignal(duration: 0.19036197662353516, isOn: false),
    MorseSignal(duration: 0.20020699501037598, isOn: true),
    MorseSignal(duration: 0.2675579786300659, isOn: false),
    MorseSignal(duration: 0.16571903228759766, isOn: true),
    MorseSignal(duration: 0.19853198528289795, isOn: false),
    MorseSignal(duration: 0.8334749937057495, isOn: true),
    MorseSignal(duration: 0.2297729253768921, isOn: false),
    MorseSignal(duration: 0.20435702800750732, isOn: true),
    MorseSignal(duration: 0.2330789566040039, isOn: false),
    MorseSignal(duration: 0.1992889642715454, isOn: true),
    MorseSignal(duration: 0.2339019775390625, isOn: false),
    MorseSignal(duration: 0.7999680042266846, isOn: true),
    MorseSignal(duration: 0.22837698459625244, isOn: false),
    MorseSignal(duration: 0.2036418914794922, isOn: true),
    MorseSignal(duration: 0.23389899730682373, isOn: false),
    MorseSignal(duration: 0.16581690311431885, isOn: true),
    MorseSignal(duration: 0.23320698738098145, isOn: false),
  ]

  let sosSignal: [MorseSignal] = [
    MorseSignal(duration: 0.2, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
    MorseSignal(duration: 0.2, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
    MorseSignal(duration: 0.2, isOn: true),
    MorseSignal(duration: 0.4, isOn: false),
    MorseSignal(duration: 0.6, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
    MorseSignal(duration: 0.6, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
    MorseSignal(duration: 0.6, isOn: true),
    MorseSignal(duration: 0.4, isOn: false),
    MorseSignal(duration: 0.2, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
    MorseSignal(duration: 0.2, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
    MorseSignal(duration: 0.2, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
  ]

  let exampleSignal = [
    MorseSignal(duration: 0.1, isOn: true),
    MorseSignal(duration: 0.1, isOn: false),
    MorseSignal(duration: 0.3, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
    MorseSignal(duration: 0.1, isOn: true),
    MorseSignal(duration: 0.4, isOn: false),
    MorseSignal(duration: 0.1, isOn: true),
    MorseSignal(duration: 0.7, isOn: false),
    MorseSignal(duration: 0.3, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
    MorseSignal(duration: 0.1, isOn: true),
    MorseSignal(duration: 0.9, isOn: false),
    MorseSignal(duration: 0.1, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
    MorseSignal(duration: 0.3, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
    MorseSignal(duration: 0.1, isOn: true),
    MorseSignal(duration: 0.2, isOn: false),
  ]

  @Test func testParseDit() {
    let element = Coder.decode(
      signal: MorseSignal(duration: 0.2, isOn: true)
    )
    #expect(element == .dit)
  }

  @Test func testParseDah() {
    let element = Coder.decode(
      signal: MorseSignal(duration: 0.6, isOn: true)
    )
    #expect(element == .dah)
  }

  @Test func testParseLetterGap() {
    let element = Coder.decode(
      signal: MorseSignal(duration: 0.6, isOn: false)
    )
    #expect(element == .letterGap)
  }

  @Test func testParseS() {
    let sSignal: [MorseSignal] = [
      MorseSignal(duration: 0.2, isOn: true),
      MorseSignal(duration: 0.2, isOn: false),
      MorseSignal(duration: 0.2, isOn: true),
      MorseSignal(duration: 0.2, isOn: false),
      MorseSignal(duration: 0.2, isOn: true),
      MorseSignal(duration: 0.2, isOn: false),
    ]
    let elements: [MorseElement] = sSignal.compactMap { Coder.decode(signal: $0) }
    #expect(elements == [.dit, .dit, .dit])
  }

  @Test func testParseDots() {
    let sElements: [MorseElement] = [
      .dit,
      .dit,
      .dit,
    ]
    let text = Coder.decode(elements: sElements)
    #expect(text == "S")
  }

  @Test func testParseSignal() {
    var elements = sosSignal.compactMap { Coder.decode(signal: $0) }
    var text = Coder.decode(elements: elements)
    #expect(text == "SOS")

    elements = exampleSignal.compactMap { Coder.decode(signal: $0) }
    text = Coder.decode(elements: elements)
    #expect(text == "SEIS")

    elements = weedSignal.compactMap { Coder.decode(signal: $0) }
    text = Coder.decode(elements: elements)
    #expect(text == "WEED A")
  }

  @Test func testAsyncCoder() async {
    let stream = Coder.encode(signal: sosSignal)

    var streamedSignal = [MorseSignal]()
    for await signal in Coder.decode(inputStream: stream) {
      streamedSignal.append(signal)
    }

    let elements = streamedSignal.compactMap { Coder.decode(signal: $0) }
    let text = Coder.decode(elements: elements)
    #expect(text == "SOS")
  }

  @Test func testAsyncEncoder() async {
    let word = "SOS TEST"
    let signals = Coder.encode(elements: Coder.encode(message: word))

    var output: [MorseSignal] = []
    var last = Date.now
    var lastSignal: Bool?

    for await signal in Coder.encode(signal: signals) {
      print("Signal \(signal) at \(Date.now.timeIntervalSinceReferenceDate)")
      if let lastSignal {
        output.append(MorseSignal(duration: -last.timeIntervalSinceNow, isOn: lastSignal))
      }
      lastSignal = signal
      last = Date.now
    }

    let elements = output.compactMap { Coder.decode(signal: $0) }
    let text = Coder.decode(elements: elements)
    #expect(text == word)
  }
}
