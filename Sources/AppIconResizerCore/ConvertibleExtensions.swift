import Commander

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
