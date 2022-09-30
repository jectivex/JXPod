import Jack
import Foundation

// MARK: TimePod

// setTimeout()
// await sleep(123)

open class TimePod : JackPod {
    public init() {
    }
    
    open var metadata: JackPodMetaData {
        JackPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    @Jack("sleep") var _sleep = sleep
    open func sleep(duration: TimeInterval) async throws {
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

    open lazy var pod = jack()
}
