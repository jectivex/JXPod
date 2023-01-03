import Foundation
import JXBridge


// MARK: ConsolePod

public protocol ConsolePod : JXPod, JXModule {
}

// console.log('message…')

/// A ``ConsolePod`` that stores messages in a buffer
open class CapturingConsolePod : JXPod, JXModule, ConsolePod {
    public let namespace: JXNamespace = "console"
    
    public var metadata: JXPodMetaData {
        JXPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    public func register(with registry: JXRegistry) throws {
    }
}

#if canImport(OSLog)
import OSLog

/// A ``ConsolePod`` that forwards logged messages to the system consle
open class OSLogConsolePod : JXPod, JXModule, ConsolePod {
    public let namespace: JXNamespace = "console"
    open var metadata: JXPodMetaData {
        JXPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    public func register(with registry: JXRegistry) throws {
    }

    public init() {
    }
}
#endif

