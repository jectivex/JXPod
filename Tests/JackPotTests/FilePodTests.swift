import JackPot
import XCTest

final class FilePodTests: XCTestCase {
    func testFilePod() async throws {
        let pod = FilePod()

        let jxc = try pod.jack().ctx

        XCTAssertEqual(3, try jxc.eval("1+2").numberValue)
        XCTAssertEqual(true, try jxc.eval("fileExists('/etc/hosts')").booleanValue)

        let tmpname = UUID().uuidString
        let tmpdir = "/tmp/testFilePod/" + tmpname

        XCTAssertEqual(false, try jxc.eval("fileExists('\(tmpdir)')").booleanValue)
        try jxc.eval("createDirectory('\(tmpdir)', true)")
        XCTAssertEqual(true, try jxc.eval("fileExists('\(tmpdir)')").booleanValue)

    }
}
