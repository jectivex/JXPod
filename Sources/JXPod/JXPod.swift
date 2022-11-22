import Foundation
import JXBridge

/// Work-in-Progress marker
@available(*, deprecated, message: "work in progress")
@inlinable internal func wip<T>(_ value: T) -> T { value }

/// A `JXPod` is a unit of native functionality that combines a `JXModule` with associated metadata.
public protocol JXPod {
    /// The metadata for this pod.
    var metadata: JXPodMetaData { get }
    
    /// Pod functionality.
    var module: JXModule { get }
}

/// Information about the pod.
public struct JXPodMetaData : Codable {
    public var homePage: URL

    public init(homePage: URL) {
        self.homePage = homePage
    }
}

extension JXPod where Self: JXModule {
    public var module: JXModule {
        return self
    }
}
