import JXKit
import JackPot
import XCTest

final class KeyPodTests: XCTestCase {
    func testKeyPod() async throws {
        let pod = KeyPod()
        let jxc = try pod.jack().ctx

        // try await jxc.eval("sleep()", priority: .high)
    }
}
