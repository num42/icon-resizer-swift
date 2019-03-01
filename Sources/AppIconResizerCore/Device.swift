import CoreImage

// Different devices with icon resolutions
public enum Device: String, CaseIterable {
    case iphone
    case ipad
    case watch
    case marketing
    case all
    
    // Grouping virtual devices in arrays based on physical devices
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
                [Device.iphone, .ipad, .watch, .marketing].map { $0.virtualDevices }.joined()
            )
        }
    }
    
    public var sizes: [CGSize] {
        return Set(virtualDevices.map { $0.sizes }.joined())
            .sorted()
            .map { CGSize(width: $0, height: $0) }
    }
}
