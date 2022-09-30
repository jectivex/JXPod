import Jack
import Foundation

// MARK: TimersPod

// setTimeout()
// await sleep(123)

public class TimersPod : JackPod {
    public var metadata: JackPodMetaData {
        JackPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    @Jack("sleep") var _sleep = sleep
    func sleep(duration: TimeInterval) async throws {
        if duration.isNaN {
            throw Errors.sleepDurationNaN
        }
        if duration < 0 {
            throw Errors.sleepDurationNegative
        }
        try await Task.sleep(nanoseconds: .init(duration * 1_000_000_000))
    }

    enum Errors : Error {
        case sleepDurationNaN
        case sleepDurationNegative
    }

    public lazy var pod = jack()
}

#if canImport(XCTest)
import XCTest

final class TimePodTests: XCTestCase {
    func testTimePod() async throws {
        let pod = TimersPod()
        let jxc = pod.jack().env

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
#endif
