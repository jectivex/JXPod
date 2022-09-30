import JackPot
import XCTest

final class NetPodTests: XCTestCase {
    func testNetPod() async throws {
        let pod = NetPod()
        //try await pod.jxc.eval("sleep()", priority: .high)
        let jxc = pod.jack().env
        XCTAssertEqual(3, try jxc.eval("1+2").numberValue)
    }
}
