import XCTest
@testable import JackPot

final class JackPotTests: XCTestCase {
    func testJackPot() throws {
        XCTAssertEqual(JackPot().text, "JackPot!")
    }
}
