import Foundation
import JXBridge
import JXKit

public class TimePod: JXPod, JXModule, JXBridging {
    public static var bundle = Bundle.module
    public static let namespace: JXNamespace = "time"
    public var jxState: JXState?

    public init() {
    }
    
    public static var metadata: JXPodMetaData {
        JXPodMetaData(source: URL(string: "https://github.com/jectivex/JXPod.git")!)
    }


    public func register(with registry: JXRegistry) throws {
        try registry.registerBridge(for: self, namespace: Self.namespace)
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
