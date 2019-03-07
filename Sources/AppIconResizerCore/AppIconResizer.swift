import Commander
import CoreImage
import Files
import Foundation

struct AppIconSetContents: Encodable {
    let iconEntries: [AppIconEntry]
    let info: Info
    
    private enum CodingKeys: String, CodingKey {
        case iconEntries = "images"
        case info
    }
    
}

struct AppIconEntry: Encodable {
    let size: CGSize
    let idiom: String
    let scale: Int

    var fileName: String {
        return "AppIcon-\(Int(size.width))x\(Int(size.height))"
    }
    
    private enum CodingKeys: String, CodingKey {
        case size
        case idiom
        case fileName = "filename"
        case scale
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(Int(size.width))x\(Int(size.height))", forKey: .size)
        try container.encode("\(scale)x", forKey: .scale)
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
        ) { [weak self] idiom, badgeFileName, fileName in
            guard let idiom = Idiom(rawValue: idiom.lowercased()) else {
                print("Error: Entered idiom is not a valid idiom! Valid idioms are \(Idiom.allCases.map { $0.rawValue }.joined(separator: ", "))")
                return
            }
            self?.render(idiom: idiom, fileName: fileName, badgeFileName: badgeFileName)
        }

        resizingCommand.run()
    }

    public func render(idiom: Idiom, fileName: String, badgeFileName: String) {
        // Get app icon entries
        let appIconEntries = idiom.appIconEntries
        
        // Write app icon entries to contents json
        
        
        let info = Info(version: 1, author: "AppIconResizer")
        let contents = AppIconSetContents(iconEntries: appIconEntries, info: info)
        do {
            let jsonData = try JSONEncoder().encode(contents)
            let jsonString = jsonData.prettyPrintedJSONString
            print(jsonString)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        
        // write png files
        let sizes = Set(appIconEntries.map{ $0.size.width }).sorted()
        
        sizes.forEach { width in
                let size = CGSize(width: width, height: width)
            
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

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
