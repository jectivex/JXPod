import Foundation
import JXBridge
import JXKit

// MARK: ConsolePod

public protocol ConsolePod : JXPod, JXModule, JXBridging {
}

// console.log('message…')

/// A ``ConsolePod`` that stores messages in a buffer
open class CapturingConsolePod : ConsolePod {
    public let namespace: JXNamespace = "console"
    public var jxState: JXState?

    public static var metadata: JXPodMetaData {
        JXPodMetaData(source: URL(string: "https://github.com/jectivex/JXPod.git")!)
    }

    public func initialize(in context: JXContext) throws {
        try context.global.integrate(self)
    }

    public func register(with registry: JXRegistry) throws {
        try registry.registerBridge(for: self, namespace: namespace)
    }
}

#if canImport(OSLog)
import OSLog

/// A ``ConsolePod`` that forwards logged messages to the system consle
open class OSLogConsolePod : ConsolePod {
    public let namespace: JXNamespace = "console"
    public var jxState: JXState?

    public static var metadata: JXPodMetaData {
        JXPodMetaData(source: URL(string: "https://github.com/jectivex/JXPod.git")!)
    }

    public func initialize(in context: JXContext) throws {
        try context.global.integrate(self)
    }

    public func register(with registry: JXRegistry) throws {
        try registry.registerBridge(for: self, namespace: namespace)
    }

    public init() {
    }

    @JXFunc var jxsleep = sleep
    public func sleep(duration: TimeInterval) async throws {
    }
}
#endif

