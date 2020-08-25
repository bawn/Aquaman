import XCTest
@testable import Aquaman

final class AquamanTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Aquaman().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
