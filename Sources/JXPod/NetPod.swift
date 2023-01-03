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

    public var metadata: JXPodMetaData {
        JXPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    public func register(with registry: JXRegistry) throws {
        try registry.registerBridge(for: self, namespace: namespace)
    }
    
    // TODO
    func fetch(url: String) async throws -> Bool {
        false
    }

}
