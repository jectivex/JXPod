import JackPot
import XCTest

final class ConsolePodTests: XCTestCase {
    #if canImport(OSLog)
    func testConsolePod() async throws {
        let pod = OSLogConsolePod()

        let jxc = try pod.jack().context
        XCTAssertEqual(3, try jxc.eval("1+2").double)
    }
    #endif
}
