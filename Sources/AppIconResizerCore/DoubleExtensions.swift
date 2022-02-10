import Foundation

extension Double {
  func withDecimals(_ decimals: Int) -> String {
    String(format: "%.\(decimals)f", self)
  }
}
