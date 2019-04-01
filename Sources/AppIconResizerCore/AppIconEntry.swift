import CoreImage

struct AppIconEntry: Encodable, Hashable, Comparable {
    static func < (lhs: AppIconEntry, rhs: AppIconEntry) -> Bool {
        return lhs.size < rhs.size
    }
    
    let size: CGFloat
    let idiom: String
    let scale: Int
    
    var scaledSize: CGFloat {
        return size * CGFloat(scale)
    }
    
    var fileName: String {
        return "AppIcon-\(Int(scaledSize))x\(Int(scaledSize)).png"
    }
    
    private enum CodingKeys: String, CodingKey {
        case size
        case idiom
        case fileName = "filename"
        case scale
    }
    
    private var displaySize: String {
        return Double(size).withDecimals(1).replacingOccurrences(of: ".0", with: "")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(displaySize)x\(displaySize)", forKey: .size)
        try container.encode("\(scale)x", forKey: .scale)
        try container.encode(idiom, forKey: .idiom)
        try container.encode(fileName, forKey: .fileName)
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

