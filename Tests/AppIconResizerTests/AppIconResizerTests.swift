import XCTest
import Files
import AppIconResizerCore
import class Foundation.Bundle
 
final class AppIconResizerTests: XCTestCase {
    func testCreatingFile() throws {
        
        // Setup a temporarz test folder that can be used as a sandbox
        let fileSystem = FileSystem()
        let tempFolder = fileSystem.temporaryFolder
        let testFolder = try tempFolder.createSubfolderIfNeeded(withName:"AppIconResizerTests")
        
        // Empty the test folder to ensure a clean state
        try testFolder.empty()
        
        // Make the temp folder the current working folder
        let fileManager = FileManager.default
        fileManager.changeCurrentDirectoryPath(testFolder.path)
        
        // Create an instance of the command line tool
        let arguments = [testFolder.path, "Hello.swift"]
        let tool = AppIconResizer(arguments:arguments)
        
        // Try to run tool and look if there is
        try tool.run()
        XCTAssertNotNil(try? testFolder.file(named: "Hello.swift"))
    }
    
    func testReadingCommand() throws {
        
        let devices = ["iphone", "ipad", "watch", "marketing", "all"]
        try devices.forEach{ device in
            let arguments = [device, "testFilePath"]
            let tool = AppIconResizer(arguments:arguments)
            try tool.run()
        }
        //NoIdea
    }
    
    func testDeviceSizes() {
        XCTAssert(
            Idiom.iphone.sizes.map { $0.width } == [40, 58, 60, 80, 87, 120, 180]
        )
        XCTAssert(
            Idiom.ipad.sizes.map { $0.width } == [20, 29, 40, 58, 76, 80, 152, 167]
        )
        XCTAssert(
            Idiom.watch.sizes.map { $0.width } == [48, 55, 58, 80, 87, 88, 100, 172, 196, 216]
        )
    }
    
    func testCreatedPngs() throws {
        let testFolder = try Folder(path: FileManager.default.currentDirectoryPath)
        //AppIconResizer.render(device:iphone, )
        XCTAssertNotNil(try? testFolder.file(named: "20.png"))
    }


    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("test", testCreatingFile),
    ]
}
