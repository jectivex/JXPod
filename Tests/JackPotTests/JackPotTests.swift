import XCTest
import Jack
import JackPot

final class JackPotTests: XCTestCase {
    func testJackPot() throws {
        class PlugIn : JackedObject {
            @Stack var num = 1
        }
    }
}
