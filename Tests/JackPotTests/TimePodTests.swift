import JXKit
import JackPot
import XCTest

final class TimePodTests: XCTestCase {
    func testTimePod() async throws {
        let pod = TimePod()
        let jxc = try pod.jack().ctx

        try await jxc.eval("sleep()", priority: .high)
        try await jxc.eval("sleep(0)", priority: .high)
        try await jxc.eval("sleep(0, 1)", priority: .high)
        try await jxc.eval("sleep(0, 1.2, 'x')", priority: .high)
        try await jxc.eval("sleep(0.0000000001)", priority: .high)

        do {
            try await jxc.eval("sleep(NaN)", priority: .high)
            XCTFail("should not have succeeded")
        } catch {
            //XCTAssertEqual("Error: sleepDurationNaN", "\(error)")
            XCTAssertEqual("Error: sleepDurationNaN", try (error as? JXError)?.stringValue)
        }
    }
}
