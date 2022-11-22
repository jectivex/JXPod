@_exported import JXKit
@_exported import JXBridge

/// A JXPod is a packaged module?
public struct JXPod {
    let module: JXModule
}


/// Work-in-Progress marker
@available(*, deprecated, message: "work in progress")
@inlinable internal func wip<T>(_ value: T) -> T { value }

