import Commander
import CoreImage
import Foundation

public final class AppIconResizer {
    
    // Create one dimensional String array 'arguments'
    private let arguments: [String]

    // Instantiate class by handing over the arguments
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        
        let resizingCommand = command(
            Option<String>("devices", default: "all"),
            Option<String?>("badge", default: nil),
            Option("targetPath", default: FileManager.default.currentDirectoryPath),
            Argument<String>("inputPath")
        ) { [weak self] idiomsString, badgeFilePath, targetPath, filePath in
            let idioms = idiomsString.components(separatedBy: ",")
                .map { idiomString -> Idiom in
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
        let contents = AppIconSetContents(iconEntries: appIconEntries.sorted(), info: info)
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
        let sizes = Set(appIconEntries.map{ $0.scaledSize }).sorted()
        
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
