import JXBridge
import Foundation

// MARK: KeyPod

// await key.keychain("login").unlock()
// let passphrase = await key.keychain("login").passphraseFor({ service: "https://example.com" });
// await key.keychain("login").lock()

open class KeyPod : JXPod, JXModule, JXBridging {
    public static let namespace: JXNamespace = "net"
    public var jxState: JXState?

    public init() {
    }

    public static var metadata: JXPodMetaData {
        JXPodMetaData(source: URL(string: "https://github.com/jectivex/JXPod.git")!)
    }

    public func register(with registry: JXRegistry) throws {
        try registry.registerBridge(for: self, namespace: Self.namespace)
    }

//    @Jack("unlock") var _unlock = unlock
//    open func unlock() async throws {
//    }

    enum Errors : Error {
        case noSuchKeychainError
        case keychainUnlockError
    }

}
