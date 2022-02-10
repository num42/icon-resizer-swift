import CoreImage

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
