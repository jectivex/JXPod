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

        func decodePreamble(_ string: String) throws -> [Metadata] {
            let data = string.data(using: .utf8) ?? Data()

            do {
                // attempt to parse the whole data blob
                return try decoder.decode([Metadata].self, from: data)
            } catch let error {
                // the convention for decoding errors is that it is an NSError with a single underlying error, which itself has a `NSJSONSerializationErrorIndex` property with the failing index; this will be the fastest way to identify where a well-formed preamble JSON may have ended and the remainder of the script begun, so we first try to parse up to the initial JSON error
                #if canImport(ObjectiveC)
                if #available(macOS 11.3, iOS 14.5, *) {
                    for e in (error as NSError).underlyingErrors {
                        if let errorIndex = (e as NSError).userInfo["NSJSONSerializationErrorIndex"] as? Int,
                           errorIndex < data.count {
                            // try again, this time parsing up until the first failure in order to extract the preamble
                            return try decoder.decode([Metadata].self, from: data[0..<errorIndex])
                        }
                    }
                }
                #endif

                // TODO: on Linux, this will be:
                // dataCorrupted(Swift.DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: Optional(Foundation.JSONError.unexpectedCharacter(ascii: 49, characterIndex: 39))))
                // we can try to parse out the index, but `Foundation.JSONError` is not public

                // we don't have access to the error index (e.g., we are running on Linux), so
                // fall back to brute-force parsing it from the beginning up to every potentially-vaid closing
                // character (which must be "]" since the metadata must be an array of objects)
                let closeBrace = "]".utf8.first

                for index in data.indices.lazy.filter({ data[$0] == closeBrace }) {
                    do {
                        return try decoder.decode([Metadata].self, from: data[0...index])
                    } catch {
                        // ignore decoding errors during brute-force parse
                    }
                }

                throw error // just throw the original error
            }
        }

        @discardableResult func succeed(_ string: String) -> JXContext {
            let ctx = JXContext(strict: true) // for script validation
            XCTAssertNoThrow(try decodePreamble(string), "preamble should have been decoded")
            XCTAssertEqual(true, try ctx.checkSyntax(string), "script should have been parsable")
            XCTAssertNoThrow(try ctx.eval(string), "script should have executed")
            return ctx
        }

        func fail(_ string: String) {
            XCTAssertThrowsError(try decodePreamble(string))
        }

        // https://gist.githubusercontent.com/marcprux/a6b4e380bc7b9abdf595470749fb68cc/raw/bc541a2129c6a75e28a9f1208b687f37dcd40df2/kenyan_counties.json

        succeed(#"[{ "name": "Name", "version": [1,2,3] }]"#)

        succeed("""
        [{ "name": "Name", "version": [1,2,3] }]
        """)

        succeed("""
        [{ "name": "Name", "version": [1,2,3] }];
        """)

        do {
            let ctx = succeed("""
            [{ "name": "Name", "version": [1,2,3] }]
            1+2;
            function rnd() { return Math.random(); }
            """)

            let ji = try ctx.global["rnd"]
            XCTAssertTrue(ji.isObject)
            XCTAssertTrue(ji.isFunction)
            XCTAssertLessThan(0, try ji.call().double)
        }

        do {
            let ctx = succeed("""
            [{ "name": "Name", "version": [1,2,3] }]
            1+2;
            var rnd = () => { return Math.random() }
            """)

            let ji = try ctx.global["rnd"]
            XCTAssertTrue(ji.isObject)
            XCTAssertTrue(ji.isFunction)
            XCTAssertLessThan(0, try ji.call().double)
        }

        do {
            let ctx = succeed("""
            [
              {
                "name": "Name",
                "version": [1, 2, 3],
                "pods": {
                    "console": [0, 0, 1],
                    "ui": [0, 0, 1]
                }
              }
            ];

            bol = false; // a boolean variable; a $bol binding symbol will be synthesized
            num = 0; // a number variable; a $num binding symbol will be synthesized
            str = "abc"; // a string variable; a $str binding symbol will be synthesized

            function rnd() {
                return ui.VStack([
                    ui.Text(`Header`),
                    ui.Slider("Slider", $num),
                ]);
            };
            """)

            let ji = try ctx.global["rnd"]
            XCTAssertTrue(ji.isObject)
            XCTAssertTrue(ji.isFunction)
            //XCTAssert(try ji.call())
        }


        fail("")

        fail("""
        """)

        // missing "version" property
        fail("""
        [{ "name": "Name" }];
        """)

        // missing "name" property
        fail("""
        [{ "version": [1,2,3] }];
        """)

        fail("""
        let metadata = [{ "name": "Name", "version": [1,2,3] }]
        """)

        fail("""
        /* comment */ [{ "name": "Name", "version": [1,2,3] }]
        """)
    }
}
