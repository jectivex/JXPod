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
        try jxc.withValues(tmpname0, tmpname1) {
            XCTAssertFalse(try jxc.eval("file.exists($0)").bool)
            try jxc.eval("file.createDirectory($0, true)")
            XCTAssertTrue(try jxc.eval("file.exists($0)").bool)
            
            XCTAssertFalse(try jxc.eval("file.exists($1)").bool)
            try jxc.eval("file.move($0, $1)")
            XCTAssertFalse(try jxc.eval("file.exists($0)").bool)
            XCTAssertTrue(try jxc.eval("file.exists($1)").bool)
            
            try jxc.eval("file.remove($1)")
        }
    }
}
