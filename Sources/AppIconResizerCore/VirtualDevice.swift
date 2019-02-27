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
    
    var scale: CGFloat {
        switch self {
        case .iPhone3x, .watch3x:
            return 3
        case .iPhone2x, .iPad2x, .watch2x:
            return 2
        default:
            return 1
        }
    }
    
    // Source:
    // https://github.com/KrauseFx/fastlane-plugin-appicon/blob/master/lib/fastlane/plugin/appicon/actions/appicon_action.rb
    
    // Gives back array of real (not virtual) sizes
    var sizes: [CGFloat] {
        let result: [CGFloat]
        switch self {
        case .iPhone2x, .iPhone3x:
            result = [20, 29, 40, 60]
        case .iPad1x:
            result = [20, 29, 40, 76]
        case .iPad2x:
            result = VirtualDevice.iPad1x.sizes + [83.5]
        case .watch2x:
            result = [24, 27.5, 29, 40, 44, 50, 86, 98, 108]
        case .watch3x:
            result = [29]
        case .marketing:
            result = [1024]
        }
        return result.map { $0 * scale }
    }
}
