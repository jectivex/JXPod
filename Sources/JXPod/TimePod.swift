import Foundation
import JXBridge
import JXKit

public class TimePod: JXPod, JXModule, JXBridging {
    public var jxState: JXState?

    public init() {
    }
    
    public var metadata: JXPodMetaData {
        JXPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }
    
    public let namespace: JXNamespace = "time"
    
    public func register(with registry: JXRegistry) throws {
        try registry.registerBridge(for: self, namespace: namespace)
    }
    
    public func initialize(in context: JXContext) throws {
        try context.global.integrate(self)
    }
    
    public enum Errors: Error {
        case sleepDurationNaN
        case sleepDurationNegative
    }
    
    // MARK: -
    
    @JXFunc var jxsleep = sleep
    public func sleep(duration: TimeInterval) async throws {
        if duration.isNaN {
            throw Errors.sleepDurationNaN
        }
        if duration < 0 {
            throw Errors.sleepDurationNegative
        }
        try await Task.sleep(nanoseconds: .init(duration * 1_000_000_000))
    }
}
