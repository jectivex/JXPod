import JXBridge
import Foundation

// MARK: KeyPod

// await key.keychain("login").unlock()
// let passphrase = await key.keychain("login").passphraseFor({ service: "https://example.com" });
// await key.keychain("login").lock()

open class KeyPod : JXPod, JXModule {
    public let namespace: JXNamespace = "net"

    public init() {
    }

    open var metadata: JXPodMetaData {
        JXPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    public func register(with registry: JXRegistry) throws {
    }

//    @Jack("unlock") var _unlock = unlock
//    open func unlock() async throws {
//    }

    enum Errors : Error {
        case noSuchKeychainError
        case keychainUnlockError
    }

}
