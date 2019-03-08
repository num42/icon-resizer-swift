import Foundation

extension Double {
    func withDecimals(_ decimals: Int) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}
