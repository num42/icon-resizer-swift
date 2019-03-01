import Commander
import CoreImage
import Files
import Foundation

struct AppIconSetContents: Encodable {
    let images: [AppIconEntry]
    let info: Info
}

struct AppIconEntry: Encodable {
    let size: CGSize
    let idiom: String
    let scale: Int

    var fileName: String {
        return "AppIcon-\(size.width)x\(size.height)"
    }
    
    private enum CodingKeys: String, CodingKey {
        case size
        case idiom
        case fileName
        case scale
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(Int(size.width))x\(Int(size.height))", forKey: .size)
        try container.encode(scale, forKey: .scale)
        try container.encode(idiom, forKey: .idiom)
        try container.encode(fileName, forKey: .fileName)
    }
}

struct Info: Encodable {
    let version: Int
    let author: String
}

public final class AppIconResizer {
    


    
    // Create one dimensional String array 'arguments'
    private let arguments: [String]

    // Instantiate class by handing over the arguments
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        let resizingCommand = command(
            Option("device", default: "all"),
            Option("badge", default:"test"),
            Argument<String>("filename")
        ) { [weak self] device, badgeFileName, fileName in
            guard let device = Device(rawValue: device.lowercased()) else {
                print("Error: Entered device is not a valid device! Valid devices are \(Device.allCases.map { $0.rawValue }.joined(separator: ", "))")
                return
            }
            self?.render(device: device, fileName: fileName, badgeFileName: badgeFileName)
        }
        
        do {
            let testImage = AppIconEntry(size: CGSize.init(width: 10, height: 10), idiom: "iphone", scale: 2)
            let testInfo = Info(version: 4, author: "TestAuthor")
            let testContents = AppIconSetContents(images: [testImage], info: testInfo)
            
            let jsonData = try JSONEncoder().encode(testContents)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)

        } catch { print(error) }

        resizingCommand.run()
    }

    public func render(device: Device, fileName: String, badgeFileName: String) {
        device.sizes
            .forEach { size in
                let currentPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

                guard let inputImage = CIImage(contentsOf: URL(fileURLWithPath: fileName, relativeTo: currentPath)) else {
                    print("Error: Input image with name \(fileName) is not valid in current path!")
                    return
                }
                
                guard let badgeImage = CIImage(contentsOf: URL(fileURLWithPath: badgeFileName, relativeTo: currentPath)) else {
                    print("Error: Badge image with name \(badgeFileName) is not valid in current path!")
                    return
                }

                guard let image = inputImage.cgImage?.resize(to: size, badgedBy: badgeImage.cgImage) else {
                    print("Error: Input image couldn't be resized")
                    return
                }

                let url = URL(fileURLWithPath: "\(Int(size.height)).png", relativeTo: currentPath) as CFURL

                guard let destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil) else {
                    print("Error: Image couldn't be written in current directory")
                    return
                }

                let bgColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
                
                let options : [AnyHashable:Any] = [
                    kCGImageDestinationBackgroundColor: bgColor as Any
                ]

                CGImageDestinationAddImage(destination, image, options as CFDictionary)
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

extension CGImage {
    func resize(to newSize: CGSize, badgedBy badge: CGImage? = nil) -> CGImage? {
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
        context.setFillColor(CGColor.white)
        context.fill(CGRect(x: 0, y: 0, width: height, height: height))
        context.draw(self, in: CGRect(x: 0, y: 0, width: height, height: height))
        
        if let badge = badge {
            context.draw(badge, in: CGRect(x: 0, y: 0, width: height, height: height))
        }

        // extract resulting image from context
        return context.makeImage()
    }
}

extension CIImage {
    var cgImage: CGImage? {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(self, from: self.extent) else {
            return nil
        }
        return cgImage
    }
}
