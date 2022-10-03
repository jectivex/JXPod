import XCTest
import Jack
import JackPot

final class JackPotTests: XCTestCase {
    func testJackPot() throws {
        class PlugIn : JackedObject {
            @Stack var num = 1
        }
    }

    func testMetadataParsing() throws {
        struct Metadata : Hashable, Codable {
            let name: String
            let version: [Int]
        }

        let decoder = JSONDecoder()

        func decodePrelude(_ string: String) throws -> Metadata {
            let data = string.data(using: .utf8) ?? Data()

            do {
                // in the rare case that a script consists exclusively of JSON,
                return try decoder.decode(Metadata.self, from: data)
            } catch let error as NSError {
                // the convention for decoding errors is that it is an NSError with a single underlying error, which itself has a `NSJSONSerializationErrorIndex` property with the failing index; this will be the fastest way to identify where a well-formed prelude JSON may have ended and the remainder of the script begun, so we first try to parse up to the initial JSON error
                if #available(macOS 11.3, iOS 14.5, *) {
                    for e in error.underlyingErrors {
                        if let errorIndex = (e as NSError).userInfo["NSJSONSerializationErrorIndex"] as? Int,
                           errorIndex < data.count {
                            // try again, this time parsing up until the first failure in order to extract the preamble
                            return try decoder.decode(Metadata.self, from: data[0..<errorIndex])
                        }
                    }
                }

                // we don't have access to the error index (e.g., we are running on Linux), so
                // fall back to brute-force parsing it from the beginning up to every potentially-vaid closing
                // character (which must be "}" since the metadata must be an object)
                let closeBrace = "}".utf8.first

                for index in data.indices.lazy.filter({ data[$0] == closeBrace }) {
                    return try decoder.decode(Metadata.self, from: data[0...index])
                }
                throw error
            }
        }

        func succeed(_ string: String) {
            XCTAssertNoThrow(try decodePrelude(string))
        }

        func fail(_ string: String) {
            XCTAssertThrowsError(try decodePrelude(string))
        }

        // https://gist.githubusercontent.com/marcprux/a6b4e380bc7b9abdf595470749fb68cc/raw/bc541a2129c6a75e28a9f1208b687f37dcd40df2/kenyan_counties.json

        succeed(#"{ "name": "Name", "version": [1,2,3] }"#)

        succeed("""
        { "name": "Name", "version": [1,2,3] }
        """)

        succeed("""
        { "name": "Name", "version": [1,2,3] };
        """)

        succeed("""
        { "name": "Name", "version": [1,2,3] }
        1+2;
        function() { }
        """)

        fail("")

        fail("""
        """)

        // missing "version" property
        fail("""
        { "name": "Name" };
        """)

        // missing "name" property
        fail("""
        { "version": [1,2,3] };
        """)

        fail("""
        let metadata = { "name": "Name", "version": [1,2,3] }
        """)

        fail("""
        /* comment */ { "name": "Name", "version": [1,2,3] }
        """)
    }
}
