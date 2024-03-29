import CoreImage

// Different idioms with icon resolutions
public enum Idiom: String, CaseIterable {
  case iphone
  case ipad
  case watch
  case marketing
  case all

  // Grouping virtual idioms in arrays based on physical devices
  var virtualDevices: [VirtualDevice] {
    switch self {
    case .iphone:
      return [.iPhone2x, .iPhone3x]
    case .ipad:
      return [.iPad1x, .iPad2x]
    case .watch:
      return [.watch2x, .watch3x]
    case .marketing:
      return [.marketing]
    case .all:
      return Array(
        [Idiom.iphone, .ipad, .watch, .marketing].map(\.virtualDevices).joined()
      )
    }
  }

  public var stringRepresentation: String {
    switch self {
    case .marketing:
      return "ios-marketing"
    case .all:
      fatalError("All does not have a string representation.")
    default:
      return self.rawValue
    }
  }

  func appIconEntries(withPrefix prefixString: String = "AppIcon-") -> [AppIconEntry] {
    Array(virtualDevices.map { $0.appIconEntries(withPrefix: prefixString) }.joined()).sorted()
  }
}
