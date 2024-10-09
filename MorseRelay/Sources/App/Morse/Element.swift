enum MorseElement {
  case dit
  case dah
  case letterGap
  case wordGap
}

extension MorseElement: ExpressibleByExtendedGraphemeClusterLiteral {
  public init(extendedGraphemeClusterLiteral: Character) {
    self =
      switch extendedGraphemeClusterLiteral {
      case ".":
        .dit
      case "-":
        .dah
      case " ":
        .letterGap
      case "/":
        .wordGap
      default:
        fatalError("Invalid character for morse element: \(extendedGraphemeClusterLiteral)")
      }
  }
}

//typealias MorseString = Array<MorseElement>
//
//extension MorseString: @retroactive ExpressibleByStringLiteral {
//  public init(stringLiteral value: String) {
//    self = value.compactMap { char in
//      .init(extendedGraphemeClusterLiteral: char)
//    }
//  }
//}
