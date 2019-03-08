import Commander
import CoreImage
import Files
import Foundation

struct AppIconSetContents: Encodable {
    let iconEntries: [AppIconEntry]?
    let info: Info
    
    private enum CodingKeys: String, CodingKey {
        case iconEntries = "images"
        case info
    }
    
}

struct AppIconEntry: Encodable, Hashable {
    let size: CGFloat
    let idiom: String
    let scale: Int

    var scaledSize: CGFloat {
        return size * CGFloat(scale)
    }
    
    var fileName: String {
        return "AppIcon-\(Int(scaledSize))x\(Int(scaledSize))"
    }
    
    private enum CodingKeys: String, CodingKey {
        case size
        case idiom
        case fileName = "filename"
        case scale
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(Int(scaledSize))x\(Int(scaledSize))", forKey: .size)
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
            VariadicOption("device", default: ["all"]),
            Option<String?>("badge", default: nil),
            Option("targetPath", default: FileManager.default.currentDirectoryPath),
            Argument<String>("inputPath")
        ) { [weak self] idiomStrings, badgeFilePath, targetPath, filePath in
            let idioms = Set(idiomStrings).map { idiomString -> Idiom in
                guard let idiom = Idiom(rawValue: idiomString.lowercased()) else{
                    fatalError("\(idiomString) is an unknown value. Valid values are \(Idiom.allCases.map { $0.rawValue }.joined(separator: ", "))")
                }
                return idiom
                
            }
            let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            
            let inputFileURL : URL
            
            let badgeFileURL : URL?
            
            if let badgeFilePath = badgeFilePath {
                if badgeFilePath.starts(with: "/") {
                    badgeFileURL = URL(fileURLWithPath: badgeFilePath)
                } else {
                    badgeFileURL = URL(fileURLWithPath: badgeFilePath, relativeTo: currentDirectoryURL)
                }
            } else {
                badgeFileURL = nil
            }
            
            if filePath.starts(with: "/") {
                inputFileURL = URL(fileURLWithPath: filePath)
            } else {
                inputFileURL = URL(fileURLWithPath: filePath, relativeTo: currentDirectoryURL)
            }
            
            
            
            
            try self?.render(idioms: idioms, inputFileURL: inputFileURL, targetPath: targetPath, badgeFileURL: badgeFileURL)
        }
        
        resizingCommand.run()
    }

    public func render(idioms: [Idiom], inputFileURL: URL, targetPath: String, badgeFileURL: URL?) throws {
        
        let fileManager = FileManager.default
        
        let targetURL = URL(fileURLWithPath: targetPath)
        let xcAssetsURL = targetURL.appendingPathComponent("AppIcon.xcassets", isDirectory: true)
        let xcAssetsJsonURL = URL(fileURLWithPath: "Contents.json", relativeTo: xcAssetsURL)
        let iconSetURL = xcAssetsURL.appendingPathComponent("AppIcon.appiconset", isDirectory: true)
        let iconSetJsonURL = URL(fileURLWithPath: "Contents.json", relativeTo: iconSetURL)
        
        //TODO: Error handling
        
        do {
            try fileManager.createDirectory(atPath: iconSetURL.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        
        // Get app icon entries
        let appIconEntriesWithDuplicates = idioms.flatMap { $0.appIconEntries }
        let appIconEntries = Array(Set<AppIconEntry>(appIconEntriesWithDuplicates))
        
        // Write app icon entries to contents json
        let info = Info(version: 1, author: "AppIconResizer")
        let outerContents = AppIconSetContents(iconEntries: nil, info: info)
        let contents = AppIconSetContents(iconEntries: appIconEntries, info: info)
        do {
            let jsonData = try JSONEncoder().encode(contents)
            let jsonInfoData = try JSONEncoder().encode(outerContents)
            let jsonString = jsonData.prettyPrintedJSONString
            let jsonInfoString = jsonInfoData.prettyPrintedJSONString
            try jsonInfoString?.write(to: xcAssetsJsonURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            try jsonString?.write(to: iconSetJsonURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        
        // write png files
        let sizes = Set(appIconEntries.map{ $0.size }).sorted()
        
        guard let inputImage = CIImage(contentsOf: inputFileURL) else {
            print("Error: Input image at path \(inputFileURL) is not valid in current path!")
            return
        }
        
        let badgeImage: CIImage?
        
        if let badgeFileURL = badgeFileURL {
            guard let nonOptionalBadgeImage = CIImage(contentsOf: badgeFileURL) else {
                print("Error: Badge image at path \(badgeFileURL.path) could not be found!")
                return
            }
            
            badgeImage = nonOptionalBadgeImage
        } else {
            badgeImage = nil
        }
        
        let bgColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        
        let options : [AnyHashable:Any] = [
            kCGImageDestinationBackgroundColor: bgColor as Any
        ]
        
        
        sizes.forEach { width in
                let size = CGSize(width: width, height: width)

                guard let image = inputImage.cgImage?.resize(to: size, badgedBy: badgeImage?.cgImage) else {
                    print("Error: Input image couldn't be resized")
                    return
                }
            
                let targetImageFileURL = URL(fileURLWithPath: "AppIcon-\(Int(size.height))x\(Int(size.width)).png", relativeTo: iconSetURL)

                guard let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: targetImageFileURL.path) as CFURL, kUTTypePNG, 1, nil) else {
                    print("Error: Image couldn't be written in current directory")
                    return
                }

                CGImageDestinationAddImage(destination, image, options as CFDictionary)
                CGImageDestinationFinalize(destination)
                print("Created AppIcon from file \(inputFileURL.path) at \(targetImageFileURL.path) in \(size)")
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
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
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

extension Optional: CustomStringConvertible where Wrapped: ArgumentConvertible {
    public var description: String {
        if let val = self {
            return "Some(\(val))"
        }
        return "None"
    }
}

extension Optional: ArgumentConvertible where Wrapped: ArgumentConvertible {
    public init(parser: ArgumentParser) throws {
        if let wrapped = parser.shift() as? Wrapped {
            self = wrapped
        } else {
            self = .none
        }
    }
}
