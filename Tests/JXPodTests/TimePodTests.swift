import JXBridge
import JXKit
import JXPod
import XCTest

final class TimePodTests: XCTestCase {
    func testTimePod() async throws {
        let jxc = JXContext()
        try jxc.registry.register(TimePod())

        try await jxc.eval("time.sleep(0)", priority: .high)
        let start = CFAbsoluteTimeGetCurrent()
        try await jxc.eval("time.sleep(0.5)", priority: .high)
        let timeTaken = CFAbsoluteTimeGetCurrent() - start
        XCTAssertTrue(timeTaken >= 0.5)
        do {
            try await jxc.eval("time.sleep(NaN)", priority: .high)
            XCTFail("should not have succeeded")
        } catch {
            XCTAssertEqual(try (error as? JXEvalError)?.string, "Error: sleepDurationNaN")
        }
    }
}
