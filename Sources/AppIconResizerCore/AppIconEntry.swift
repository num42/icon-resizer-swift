import CoreImage

struct AppIconEntry: Encodable, Hashable, Comparable {
  static func < (lhs: AppIconEntry, rhs: AppIconEntry) -> Bool {
    if lhs.idiom != rhs.idiom {
      return lhs.idiom < rhs.idiom
    }

    if lhs.scale != rhs.scale {
      return lhs.scale < rhs.scale
    }

    return lhs.size < rhs.size
  }

  let prefixString: String
  let size: CGFloat
  let idiom: String
  let scale: Int

  var scaledSize: CGFloat {
    size * CGFloat(scale)
  }

  func fileName(for prefix: String) -> String {
    "\(prefix)\(Int(scaledSize))x\(Int(scaledSize)).png"
  }

  private enum CodingKeys: String, CodingKey {
    case size
    case idiom
    case fileName = "filename"
    case scale
  }

  private var displaySize: String {
    Double(size).withDecimals(1).replacingOccurrences(of: ".0", with: "")
  }

  init(
    prefixString: String = "AppIcon-",
    size: CGFloat,
    idiom: String,
    scale: Int
  ) {
    self.prefixString = prefixString
    self.size = size
    self.idiom = idiom
    self.scale = scale
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode("\(displaySize)x\(displaySize)", forKey: .size)
    try container.encode("\(scale)x", forKey: .scale)
    try container.encode(idiom, forKey: .idiom)
    try container.encode(fileName(for: prefixString), forKey: .fileName)
  }
}

struct AppIconSetContents: Encodable {
  let iconEntries: [AppIconEntry]?
  let info: Info

  private enum CodingKeys: String, CodingKey {
    case iconEntries = "images"
    case info
  }
}

struct Info: Encodable {
  let version: Int
  let author: String
}
