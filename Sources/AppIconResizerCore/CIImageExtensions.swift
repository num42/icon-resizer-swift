import CoreImage

extension CIImage {
  var cgImage: CGImage? {
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(self, from: self.extent) else {
      return nil
    }
    return cgImage
  }
}
