import Commander
import CoreImage
import Files
import Foundation

public final class AppIconResizer {
    // Different devices with icon resolutions
    public enum Device: String {
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

    // Create one dimensional String array 'arguments'
    private let arguments: [String]

    // Instantiate class by handing over the arguments
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        let resizingCommand = command(
            Option("device", default: "all"),
            Argument<String>("filename")
        ) { [weak self] device, fileName in
            guard let device = Device(rawValue: device.lowercased()) else {
                // TODO: Print error
                return
            }

            self?.render(device: device, fileName: fileName)
        }

        resizingCommand.run()
    }

    public func render(device: Device, fileName: String) {
        device.sizes
            .forEach { size in
                let currentPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

                guard let inputImage = CIImage(contentsOf: URL(fileURLWithPath: fileName, relativeTo: currentPath)) else {
                    // TODO: Print error
                    return
                }

                guard let image = convertCIImageToCGImage(inputImage: inputImage)?.resize(to: size) else {
                    // TODO: Print error
                    return
                }

                let url = URL(fileURLWithPath: "\(Int(size.height)).png", relativeTo: currentPath) as CFURL
                
                guard let destination = CGImageDestinationCreateWithURL(url,kUTTypePNG,1,nil) else {
                    // TODO: Print error
                    return
                }

                CGImageDestinationAddImage(destination, image, nil)
                CGImageDestinationFinalize(destination)
                print("Created AppIcon from \(fileName) in \(size)")
            }
    }
}

public extension AppIconResizer {
    enum Error: Swift.Error {
        case missingFileName
        case failedToCreateFile
    }
}

func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    // TODO: make this a guard
    if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
        return cgImage
    }
    return nil
}

extension CGImage {
    func resize(to newSize: CGSize) -> CGImage? {
        let height = Int(newSize.height)

        guard let colorSpace = self.colorSpace else {
            return nil
        }

        guard let context = CGContext(
            data: nil,
            width: height,
            height: height,
            bitsPerComponent: self.bitsPerComponent,
            bytesPerRow: self.bytesPerRow,
            space: colorSpace,
            bitmapInfo: self.alphaInfo.rawValue
        ) else {
            return nil
        }

        // draw image to context (resizing it)
        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: height, height: height))

        // extract resulting image from context
        return context.makeImage()
    }
}
