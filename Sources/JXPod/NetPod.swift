import Foundation
import JXBridge

// MARK: NetPod

// fetch('https://example.org/resource.json')

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class NetPod : JXPod, JXModule, JXBridging {
    public static let namespace: JXNamespace = "net"
    public var jxState: JXState?
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public static var metadata: JXPodMetaData {
        JXPodMetaData(source: URL(string: "https://github.com/jectivex/JXPod.git")!)
    }

    public func register(with registry: JXRegistry) throws {
        try registry.registerBridge(for: self, namespace: Self.namespace)
    }
    
    // TODO
    func fetch(url: String) async throws -> Bool {
        false
    }

}
