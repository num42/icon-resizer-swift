import Foundation
import Commander
import Files
import CoreImage

public final class AppIconResizer {
    
    
    
    // Create one dimensional String array 'arguments'
    private let arguments: [String]
    
    // Instanciate class by handing over the arguments
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        
        let resizingCommand = command (
            Option("device", default: "all"),
            Argument<String>("filename")
        ) { [weak self] device, fileName in
            guard let device = Device(rawValue: device.lowercased()) else {
                print("Error! Invalid command!")
                return
            }
            self?.render(device: device, fileName: fileName)
        }
        resizingCommand.run()
    }
    
    public func render(device: Device, fileName:String) {
        device.sizes
            .forEach { size in
                let currentPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                let image = convertCIImageToCGImage(inputImage: CIImage(contentsOf: URL(fileURLWithPath: fileName, relativeTo: currentPath))!)?.resize(to: size)
                let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: "\(Int(size.height)).png", relativeTo: currentPath) as CFURL, kUTTypePNG, 1, nil)
                CGImageDestinationAddImage(destination!, image!, nil)
                CGImageDestinationFinalize(destination!)
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
    if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
        return cgImage
    }
    return nil
}

extension CGImage {
    func resize(to newSize: CGSize) -> CGImage? {
        let inputImageHeight = CGFloat(self.height)
        
        // Get ratio (landscape or portrait)
        var ratio = newSize.height / inputImageHeight
        
        // Calculate new size based on the ratio
        if ratio > 1 {
            ratio = 1
        }
        let height = newSize.height
        
        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(data: nil,
                                      width: Int(height),
                                      height: Int(height),
                                      bitsPerComponent: self.bitsPerComponent,
                                      bytesPerRow: self.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: self.alphaInfo.rawValue)
            else { return nil }
        
        // draw image to context (resizing it)
        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: Int(height), height: Int(height)))
        
        // extract resulting image from context
        return context.makeImage()
    }
}


        



