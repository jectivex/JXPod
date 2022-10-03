import JackPot
import XCTest

#if canImport(CoreLocation)
import CoreLocation

final class LocationGeoPodTests: XCTestCase {
    func testLocationGeoPod() async throws {
        let pod = CoreLocationGeoPod()
        let jxc = try pod.jack().ctx
        //try await jxc.eval("sleep()", priority: .high)
        XCTAssertEqual(3, try jxc.eval("1+2").numberValue)
    }
}
#endif
