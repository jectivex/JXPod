import Jack
import Foundation

// MARK: KeyPod

// await key.keychain("login").unlock()
// let passphrase = await key.keychain("login").passphraseFor({ service: "https://example.com" });
// await key.keychain("login").lock()

open class KeyPod : JackPod {
    public init() {
    }
    
    open var metadata: JackPodMetaData {
        JackPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    @Jack("unlock") var _unlock = unlock
    open func unlock() async throws {
    }

    enum Errors : Error {
        case noSuchKeychainError
        case keychainUnlockError
    }

}
