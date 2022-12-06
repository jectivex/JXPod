import XCTest
import Jack
import JXPod
import JXBridge
import FairCore

final class JXPodTests: XCTestCase {
    func testJXPod() throws {
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

    func testPlugins() throws {
        // XCTAssertEqual(true, try Bundle(for: FairPod1.self).registerDynamic(name: "FairPod1"))
        // XCTAssertEqual(true, try Bundle(for: FairPod2.self).registerDynamic(name: "FairPod2"))
        // XCTAssertThrowsError(try Bundle(for: FairPodX.self).registerDynamic(name: "FairPodX"))
        XCTAssertEqual(true, try Bundle(for: Self.self).registerDynamic(name: "FairPodXXX", in: nil))
        XCTAssertEqual(true, try Bundle(for: Self.self).registerDynamic(name: "FairPodZZZ", in: nil))
    }

    func testPodMetadata() throws {
        let metadatas = try JSum.parse(yamls: """
        module: 'abc'
        pods:
          - name: 'SimplePod'
            requires:
              - name: 'ConsolePod'
                version: '1.0'
              - name: 'UIPod'
                version: '0.0.1'
            localizations:
              fr:
                name: 'Le Pod Simple'
                description: 'le pod simple est cool!'

          - name: 'Standard2Pod'
            requires:
              - name: 'ConsolePod'
                version: '1.0'
            run: |
              console.log('Hello World');

          - name: 'UIPod'
            requires:
              - name: 'ConsolePod'
                version: '1.0'

          - name: 'ConsolePod'

          - name: 'someUser/SomePod'

          - name: 'https://gitlab.com/SomeUser2/SomePod'
        ---
        module: 'xyz'
        pods:
          - name: 'ComplexPod'
        """)

        let modules = try [PodMetadata](jsum: .arr(metadatas))

        XCTAssertEqual(2, modules.count)
        guard let m1 = modules.first else {
            return XCTFail("no first module")
        }
        XCTAssertEqual("abc", m1.module)
        XCTAssertEqual(6, m1.pods.count)
        XCTAssertEqual("SimplePod", m1.pods.first?.name)

        XCTAssertEqual("ConsolePod", m1.pods.first?.requires?.first?.name)
        XCTAssertEqual("1.0", m1.pods.first?.requires?.first?.version)
        XCTAssertEqual("UIPod", m1.pods.first?.requires?.last?.name)
        XCTAssertEqual("0.0.1", m1.pods.first?.requires?.last?.version)
        XCTAssertEqual("Le Pod Simple", m1.pods.first?.localizations?["fr"]?.name)

        let pod2 = m1.pods.dropFirst().first
        XCTAssertEqual("Standard2Pod", pod2?.name)
        XCTAssertEqual("ConsolePod", pod2?.requires?.first?.name)
        XCTAssertEqual("console.log('Hello World');", pod2?.run?.trimmingCharacters(in: .newlines))

        XCTAssertEqual("https://gitlab.com/SomeUser2/SomePod", m1.pods.last?.name)

        guard let m2 = modules.last else {
            return XCTFail("no last module")
        }
        XCTAssertEqual("xyz", m2.module)
        XCTAssertEqual("ComplexPod", m2.pods.first?.name)
    }
}

public struct PodMetadata : Decodable {
    public var module: String
    public var pods: [Pod]

    public struct Pod : Decodable {
        public var name: String
        public var description: String?
        public var requires: [Requirement]?
        public var run: String?
        public var script: String?
        public var localizations: [String: Self]?

        public struct Requirement : Decodable {
            public var name: String?
            public var version: String?
        }
    }
}

public protocol PodFactory {
    static func createPod(in context: PodFactoryContext, with configuration: PodMetadata.Pod) -> Self
}

public protocol PodFactoryContext {
}

public class PodRegistry {
    public static func registerPod<PF: PodFactory>(_ type: PF.Type) -> Bool {
        //wip(true)
        true
    }
}


actor ActorFilePod : PodFactory {
    let context: PodFactoryContext
    let configuration: PodMetadata.Pod

    private init(context: PodFactoryContext, configuration: PodMetadata.Pod) {
        self.context = context
        self.configuration = configuration
    }

    static func createPod(in context: PodFactoryContext, with configuration: PodMetadata.Pod) -> ActorFilePod {
        ActorFilePod(context: context, configuration: configuration)
    }
}


// MARK: Experimental Pod Metadata

extension DemoTimePod : PodFactory {
    public static func createPod(in context: PodFactoryContext, with configuration: PodMetadata.Pod) -> DemoTimePod {
        DemoTimePod(context: context, configuration: configuration)
    }
}

final class DemoTimePod: JXPod, JXModule, JXBridging {
    public let context: PodFactoryContext
    public let configuration: PodMetadata.Pod
    public let metadata: JXPodMetaData = JXPodMetaData(homePage: URL(string: "https://www.example.com")!)

    private init(context: PodFactoryContext, configuration: PodMetadata.Pod) {
        self.context = context
        self.configuration = configuration
    }

    public let namespace: JXNamespace = "time"

    public func register(with registry: JXRegistry) async throws {
        try registry.registerBridge(for: self, namespace: namespace)
    }

    public func initialize(in context: JXContext) async throws {
        try context.global.integrate(self)
    }

    public enum Errors: Error {
        case sleepDurationNaN
        case sleepDurationNegative
    }

    // MARK: -

    // not working
    //@JXFunc var jxsleep: (isolated TimePod) -> (TimeInterval) async throws -> () = Optional.none!

    @JXFunc var jxsleep = sleep
    public func sleep(duration: TimeInterval) async throws {
        if duration.isNaN {
            throw Errors.sleepDurationNaN
        }
        if duration < 0 {
            throw Errors.sleepDurationNegative
        }
        try await Task.sleep(nanoseconds: .init(duration * 1_000_000_000))
    }
}


@_cdecl("registerFairPodXXX")
func registerFairPodXXX() -> Bool {
    PodRegistry.registerPod(ActorFilePod.self)
}

@_cdecl("registerFairPodZZZ")
func registerFairPodZZZ() -> Bool {
    PodRegistry.registerPod(DemoTimePod.self)
}
