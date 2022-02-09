import Foundation

// enum of virtual devices
public enum VirtualDevice {
  case iPhone2x
  case iPhone3x
  case iPad1x
  case iPad2x
  case watch2x
  case watch3x
  case marketing

  // Assigning multiplication factors to different devices

  var scale: Int {
    switch self {
    case .iPhone3x, .watch3x:
      return 3
    case .iPhone2x, .iPad2x, .watch2x:
      return 2
    default:
      return 1
    }
  }

  var idiom: Idiom {
    switch self {
    case .iPhone2x, .iPhone3x:
      return .iphone
    case .iPad1x, .iPad2x:
      return .ipad
    case .watch2x, .watch3x:
      return .watch
    case .marketing:
      return .marketing
    }
  }

  // Source:
  // https://github.com/KrauseFx/fastlane-plugin-appicon/blob/master/lib/fastlane/plugin/appicon/actions/appicon_action.rb

  // Gives back app icon entries
  func appIconEntries(withPrefix prefixString: String) -> [AppIconEntry] {
    let sizes: [CGFloat]
    switch self {
    case .iPhone2x, .iPhone3x:
      sizes = [20, 29, 40, 60]
    case .iPad1x:
      sizes = [20, 29, 40, 76]
    case .iPad2x:
      sizes = [20, 29, 40, 76, 83.5]
    case .watch2x:
      sizes = [24, 27.5, 29, 40, 44, 50, 86, 98, 108]
    case .watch3x:
      sizes = [29]
    case .marketing:
      sizes = [1024]
    }
    let appIconEntries = sizes
      .map { AppIconEntry(prefixString: prefixString, size: $0, idiom: idiom.stringRepresentation, scale: scale) }
    return appIconEntries
  }
}
