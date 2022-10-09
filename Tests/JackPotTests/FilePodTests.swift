import JackPot
import XCTest

final class FilePodTests: XCTestCase {
    func testFilePod() async throws {
        let pod = FilePod()

        let jxc = try pod.jack().context

        XCTAssertEqual(3, try jxc.eval("1+2").double)
        XCTAssertEqual(true, try jxc.eval("fileExists('/etc/hosts')").bool)

        let tmpname = UUID().uuidString
        let tmpdir = "/tmp/testFilePod/" + tmpname

        XCTAssertEqual(false, try jxc.eval("fileExists('\(tmpdir)')").bool)
        try jxc.eval("createDirectory('\(tmpdir)', true)")
        XCTAssertEqual(true, try jxc.eval("fileExists('\(tmpdir)')").bool)

    }
}
