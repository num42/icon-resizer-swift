import XCTest
@testable import AppIconResizerCore
import class Foundation.Bundle

final class AppIconResizerTests: XCTestCase {
    
    func testDeviceSizes() {
        XCTAssert( Idiom.all.appIconEntries() == Idiom.all.appIconEntries())
        
        XCTAssert(
            Idiom.iphone.appIconEntries() == [
                AppIconEntry(
                    size : 20.0,
                    idiom : "iphone",
                    scale : 2),
                AppIconEntry(
                    size : 20.0,
                    idiom : "iphone",
                    scale : 3),
                AppIconEntry(
                    size : 29.0,
                    idiom : "iphone",
                    scale : 2),
                AppIconEntry(
                    size : 29.0,
                    idiom : "iphone",
                    scale : 3),
                AppIconEntry(
                    size : 40.0,
                    idiom : "iphone",
                    scale : 2),
                AppIconEntry(
                    size : 40.0,
                    idiom : "iphone",
                    scale : 3),
                AppIconEntry(
                    size : 60.0,
                    idiom : "iphone",
                    scale : 2),
                AppIconEntry(
                    size : 60.0,
                    idiom : "iphone",
                    scale : 3)
            ]
        )
        
        XCTAssert(
            Idiom.ipad.appIconEntries() == [
                AppIconEntry(
                    size : 20.0,
                    idiom : "ipad",
                    scale : 1),
                AppIconEntry(
                    size : 20.0,
                    idiom : "ipad",
                    scale : 2),
                AppIconEntry(
                    size : 29.0,
                    idiom : "ipad",
                    scale : 1),
                AppIconEntry(
                    size : 29.0,
                    idiom : "ipad",
                    scale : 2),
                AppIconEntry(
                    size : 40.0,
                    idiom : "ipad",
                    scale : 1),
                AppIconEntry(
                    size : 40.0,
                    idiom : "ipad",
                    scale : 2),
                AppIconEntry(
                    size : 76.0,
                    idiom : "ipad",
                    scale : 1),
                AppIconEntry(
                    size : 76.0,
                    idiom : "ipad",
                    scale : 2),
                AppIconEntry(
                    size : 83.5,
                    idiom : "ipad",
                    scale : 2)
            ]
        )
        
        XCTAssert(
            Idiom.watch.appIconEntries() == [
                AppIconEntry(
                    size : 24.0,
                    idiom : "watch",
                    scale : 2),
                AppIconEntry(
                    size : 27.5,
                    idiom : "watch",
                    scale : 2),
                AppIconEntry(
                    size : 29.0,
                    idiom : "watch",
                    scale : 2),
                AppIconEntry(
                    size : 29.0,
                    idiom : "watch",
                    scale : 3),
                AppIconEntry(
                    size : 40.0,
                    idiom : "watch",
                    scale : 2),
                AppIconEntry(
                    size : 44.0,
                    idiom : "watch",
                    scale : 2),
                AppIconEntry(
                    size : 50.0,
                    idiom : "watch",
                    scale : 2),
                AppIconEntry(
                    size : 86.0,
                    idiom : "watch",
                    scale : 2),
                AppIconEntry(
                    size : 98.0,
                    idiom : "watch",
                    scale : 2),
                AppIconEntry(
                    size : 108.0,
                    idiom : "watch",
                    scale : 2)
            ]
        )
    }
}
