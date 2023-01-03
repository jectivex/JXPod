import JXBridge
import JXKit
import JXPod
import XCTest

final class TimePodTests: XCTestCase {
    func testTimePod() async throws {
        let jxc = JXContext()
        try jxc.registry.register(TimePod())

        _ = try await jxc.eval("time.sleep(0)").awaitPromise(priority: .high)
        let start = Date().timeIntervalSinceReferenceDate
        _ = try await jxc.eval("time.sleep(0.5)").awaitPromise(priority: .high)
        let timeTaken = Date().timeIntervalSinceReferenceDate - start
        XCTAssertTrue(timeTaken >= 0.5)
        do {
            _ = try await jxc.eval("time.sleep(NaN)").awaitPromise(priority: .high)
            XCTFail("should not have succeeded")
        } catch {
            //XCTAssertEqual(try (error as? JXEvalError)?.string, "Error: sleepDurationNaN")
        }

        let result = try await jxc.eval("(async () => { await time.sleep(0.01); return 999; })()").awaitPromise(priority: .high)
        XCTAssertEqual(999, try result.int)
    }
}
