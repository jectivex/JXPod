import JXBridge
import JXKit
import JXPod
import XCTest

final class FilePodTests: XCTestCase {
    func testFilePod() throws {
        let jxc = JXContext()
        try jxc.registry.register(FilePod())

        XCTAssertEqual(true, try jxc.eval("file.exists('/etc/hosts')").bool)
        XCTAssertTrue(try jxc.eval("file.exists(file.temporaryDirectory)").bool)
        let tmpdir = try jxc.eval("file.temporaryDirectory").string
    
        let tmpname0 = tmpdir + "/" + UUID().uuidString
        let tmpname1 = tmpdir + "/" + UUID().uuidString
        let eval = { try jxc.evalClosure($0, withArguments: [tmpname0, tmpname1]) }

        XCTAssertFalse(try eval("file.exists($0)").bool)
        _ = try eval("file.createDirectory($0, true)")
        //XCTAssertTrue(try eval("file.exists($0)").bool)

        XCTAssertFalse(try eval("file.exists($1)").bool)
        _ = try eval("file.move($0, $1)")
        XCTAssertFalse(try eval("file.exists($0)").bool)
        //XCTAssertTrue(try eval("file.exists($1)").bool)

        _ = try eval("file.remove($1)")
    }
}
