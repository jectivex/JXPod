import Foundation
import JXKit
import JXBridge

/// Work-in-Progress marker
@available(*, deprecated, message: "work in progress")
@inlinable internal func wip<T>(_ value: T) -> T { value }

// TODO: replace or extend JXModule?

/// A `JXPod` is a unit of native functionality that combines a `JXModule` with associated metadata.
public protocol JXPod {
    /// The metadata for this pod, which can be used for querying the available versions.
    static var metadata: JXPodMetaData { get }
    
    /// The module for this pod..
    var module: JXModule { get }
}

/// Information about the pod.
public struct JXPodMetaData : Codable {
    public var source: URL

    public init(source: URL) {
        self.source = source
    }
}

extension JXPod where Self: JXModule {
    public var module: JXModule {
        return self
    }
}
