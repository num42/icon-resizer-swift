import Foundation

extension Array {
  func parallelForEach(_ body: (Element) -> Void) {
    DispatchQueue.concurrentPerform(iterations: count) { index in
      body(self[index])
    }
  }
}
