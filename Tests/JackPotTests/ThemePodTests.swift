import Jack
import JackPot
import XCTest

final class ThemePodTests: XCTestCase {

    func testColor() async throws {
        XCTAssertEqual(1, CSSColor.NamedColor(rawValue: "red")?.color.r)
        XCTAssertEqual(0.5019607843137255, CSSColor.NamedColor(rawValue: "green")?.color.g)
        XCTAssertEqual(1, CSSColor.NamedColor(rawValue: "blue")?.color.b)

        XCTAssertEqual("#112233FF", CSSColor.RGBColor(integerLiteral: 0x112233).description)


        let decoder = JSONDecoder()

        @discardableResult func parse(_ color: String, quote: Bool = true) throws -> CSSColor {
            do {
                let color = try decoder.decode(CSSColor.self, from: (quote ? ("\"" + color + "\"") : color).data(using: .utf8) ?? Data())
                return color
            } catch {
                XCTFail("\(error)")
                throw error
            }
        }

        XCTAssertEqual("\"blue\"", try parse("blue").description)
        XCTAssertEqual("#7FFFB2", try parse(#"{ "r": 0.5, "g": 1.0, "b": 0.7 }"#, quote: false).description)
        XCTAssertEqual("#7FFFB2BF", try parse(#"{ "r": 0.5, "g": 1.0, "b": 0.7, "a": 0.75 }"#, quote: false).description)

        // color samples from https://developer.mozilla.org/en-US/docs/Web/CSS/color_value

        try parse("transparent")
        try parse("black")
        try parse("silver")
        try parse("gray")
        try parse("white")
        try parse("aliceblue")
        try parse("forestgreen")
        try parse("gainsboro")
        try parse("ghostwhite")
        try parse("gold")
        try parse("goldenrod")
        try parse("greenyellow")
        try parse("grey")
        try parse("honeydew")
        try parse("hotpink")
        try parse("indianred")
        try parse("indigo")
        try parse("ivory")
        try parse("khaki")
        try parse("lavender")
        try parse("oldlace")
        try parse("olivedrab")
        try parse("orangered")
        try parse("orchid")
        try parse("turquoise")
        try parse("violet")
        try parse("wheat")
        try parse("whitesmoke")
        try parse("yellowgreen")


        /* These syntax variations all specify the same color: a fully opaque hot pink. */

        /* Hexadecimal syntax */
        XCTAssertEqual("#0F0009", try parse("#f09").description)
        XCTAssertEqual("#0F0009", try parse("#F09").description)
        XCTAssertEqual("#FF0099", try parse("#ff0099").description)
        XCTAssertEqual("#FF0099", try parse("#FF0099").description)

        //        /* Functional syntax */
        //        try parse ("rgb(255,0,153)")
        //        try parse ("rgb(255, 0, 153)")
        //        try parse ("rgb(255, 0, 153.0)")
        //        try parse ("rgb(100%,0%,60%)")
        //        try parse ("rgb(100%, 0%, 60%)")
        //        try parse ("rgb(100%, 0, 60%)") /* ERROR! Don't mix numbers and percentages. */
        //        try parse ("rgb(255 0 153)")

        /* Hexadecimal syntax with alpha value */
        XCTAssertEqual("#0F00090F", try parse("#f09f").description)
        XCTAssertEqual("#0F00090F", try parse("#F09F").description)
        XCTAssertEqual("#FF0099FF", try parse("#ff0099ff").description)
        XCTAssertEqual("#FF0099FF", try parse("#FF0099FF").description)

        //        /* Functional syntax with alpha value */
        //        try parse("rgb(255, 0, 153, 1)")
        //        try parse("rgb(255, 0, 153, 100%)")
        //
        //        /* Whitespace syntax */
        //        try parse("rgb(255 0 153 / 1)")
        //        try parse("rgb(255 0 153 / 100%)")
        //
        //        /* Functional syntax with floats value */
        //        try parse("rgb(255, 0, 153.6, 1)")
        //        try parse("rgb(2.55e2, 0e0, 1.53e2, 1e2%)")

        // RGB transparency variations

        /* Hexadecimal syntax */
        try parse("#3a30")                    /*   0% opaque green */
        try parse("#3A3F")                    /* full opaque green */
        try parse("#33aa3300")                /*   0% opaque green */
        try parse("#33AA3380")                /*  50% opaque green */

        // /* Functional syntax */
        // try parse("rgba(51, 170, 51, .1)")    /*  10% opaque green */
        // try parse("rgba(51, 170, 51, .4)")    /*  40% opaque green */
        // try parse("rgba(51, 170, 51, .7)")    /*  70% opaque green */
        // try parse("rgba(51, 170, 51,  1)")    /* full opaque green */
        //
        // /* Whitespace syntax */
        // try parse("rgba(51 170 51 / 0.4)")    /*  40% opaque green */
        // try parse("rgba(51 170 51 / 40%)")    /*  40% opaque green */
        //
        // /* Functional syntax with floats value */
        // try parse("rgba(51, 170, 51.6, 1)")
        // try parse("rgba(5.1e1, 1.7e2, 5.1e1, 1e2%)")

        // HSL syntax variations

        /* These examples all specify the same color: a lavender. */
        // try parse("hsl(270,60%,70%)")
        // try parse("hsl(270, 60%, 70%)")
        // try parse("hsl(270 60% 70%)")
        // try parse("hsl(270deg, 60%, 70%)")
        // try parse("hsl(4.71239rad, 60%, 70%)")
        // try parse("hsl(.75turn, 60%, 70%)")

        /* These examples all specify the same color: a lavender that is 15% opaque. */
        // try parse("hsl(270, 60%, 50%, .15)")
        // try parse("hsl(270, 60%, 50%, 15%)")
        // try parse("hsl(270 60% 50% / .15)")
        // try parse("hsl(270 60% 50% / 15%)")

        // HWB syntax variations

        /* These examples all specify varying shades of a lime green. */
        // hwb(90 10% 10%)
        // hwb(90 50% 10%)
        // hwb(90deg 10% 10%)
        // hwb(1.5708rad 60% 0%)
        // hwb(.25turn 0% 40%)
        //
        // /* Same lime green but with an alpha value */
        // hwb(90 10% 10% / 0.5)
        // hwb(90 10% 10% / 50%)

        // HSL transparency variations
        // try parse("hsla(240, 100%, 50%, .05)")     /*   5% opaque blue */
        // try parse("hsla(240, 100%, 50%, .4)")      /*  40% opaque blue */
        // try parse("hsla(240, 100%, 50%, .7)")      /*  70% opaque blue */
        // try parse("hsla(240, 100%, 50%, 1)")       /* full opaque blue */

        /* Whitespace syntax */
        // try parse("hsla(240 100% 50% / .05)")      /*   5% opaque blue */

        /* Percentage value for alpha */
        // try parse("hsla(240 100% 50% / 5%)")       /*   5% opaque blue */
    }

    @MainActor func testThemePod() async throws {
        let pod = ThemePod()
        let jxc = pod.jack().env

        //try await jxc.eval("sleep()", priority: .high)
        XCTAssertEqual(3, try jxc.eval("1+2").numberValue)

        try jxc.global.set("c", convertible: CSSColor(rgb: CSSColor.RGBColor(r: 0.1, g: 0.2, b: 0.3)))
        XCTAssertEqual(#"{"r":0.1,"g":0.2,"b":0.3}"#, try jxc.eval("JSON.stringify(c)").stringValue)

        try jxc.global.set("c", convertible: CSSColor(name: CSSColor.NamedColor.aqua))
        XCTAssertEqual(#""aqua""#, try jxc.eval("JSON.stringify(c)").stringValue)

        pod.backgroundColor = .init(.init(name: .aqua))
        XCTAssertEqual(#""aqua""#, try jxc.eval("JSON.stringify(backgroundColor)").stringValue)

        // eventually we can do this

//        try jxc.eval("""
//        var blue = 0.8;
//
//        navbarTint = { r: 0.5, g: 1.0, b: blue, a: 0.75 };
//        textColor = { r: 0.5, g: 1.0, b: blue, a: 0 }
//        backgroundColor = 'red';
//        """)

        #if canImport(UIKit)
        XCTAssertEqual(false, try jxc.eval("navBarTintColor").isUndefined)
        XCTAssertEqual(true, try jxc.eval("navBarTintColor").isNull)

        XCTAssertThrowsError(try jxc.eval("navBarTintColor = { X: 1.0, g: 0.5, b: 0.8, a: 1.0 };"))

        XCTAssertThrowsError(try jxc.eval("navBarTintColor = 'not a color';"))
        XCTAssertNoThrow(try jxc.eval("navBarTintColor = 'pink';"))

        try jxc.eval("navBarTintColor = { r: 1.0, g: 0.5, b: 0.8, a: 1.0 };")

        XCTAssertEqual(false, try jxc.eval("navBarTintColor").isUndefined)
        XCTAssertEqual(false, try jxc.eval("navBarTintColor").isNull)
        XCTAssertEqual(true, try jxc.eval("navBarTintColor").isObject)
        XCTAssertEqual(#"{"r":1,"g":0.5,"b":0.8,"a":1}"#, try jxc.eval("JSON.stringify(navBarTintColor)").stringValue)

        #endif
    }

    func testDidSet() throws {
        class TestObject : JackedObject {
            @Pack public var XXX: String = "" {
                didSet {
                    testDidSetCount += 1
                }
            }

            lazy var jxc = jack()
        }

        XCTAssertEqual(0, testDidSetCount)
        let ob = TestObject()
        ob.XXX = "XYZ";
        XCTAssertEqual(1, testDidSetCount)

        let cancellable = ob.$XXX.sink { val in
            testDidSetCount += 1 // fired twice
        }

        try ob.jxc.env.eval("XXX = 'abc';") // doesn't invoke didSet
        XCTAssertEqual(3, testDidSetCount) // TODO: didSet is not getting called from the JS side; need to fix this

        ob.XXX = "XYZ";
        XCTAssertEqual(5, testDidSetCount) // once from didSet, once from the cancellable

        let _ = cancellable
    }

}

var testDidSetCount = 0
