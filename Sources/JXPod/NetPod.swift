import Foundation
import JXBridge

// MARK: NetPod

// fetch('https://example.org/resource.json')

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class NetPod : JXPod, JXModule, JXBridging {
    public let namespace: JXNamespace = "net"
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public static var metadata: JXPodMetaData {
        JXPodMetaData(source: URL(string: "https://github.com/jectivex/JXPod.git")!)
    }

    public func register(with registry: JXRegistry) throws {
        try registry.registerBridge(for: self, namespace: namespace)
    }
    
    // TODO
    func fetch(url: String) async throws -> Bool {
        false
    }

}
