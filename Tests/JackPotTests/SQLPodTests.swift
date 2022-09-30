import JackPot
import XCTest

final class SQLPodTests: XCTestCase {

    #if canImport(SQLite3)
    func testSQLitePod() async throws {
        let pod = SQLitePod()
        let jxc = pod.jack().env
        //try await pod.jxc.eval("sleep()", priority: .high)
        XCTAssertEqual(3, try jxc.eval("1+2").numberValue)
    }
    #endif
}
