import JXBridge
import Foundation

// MARK: ThemePod

// theme.backgroundColor = 'purple';
// theme.defaultTabItemHighlight = 'red';

open class ThemePod : JXPod, JXModule {
    public let namespace: JXNamespace = "theme"

    /// Should this be shared instead?
    public init() {
        setupListeners()
    }

    open var metadata: JXPodMetaData {
        JXPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    //@Stack open var backgroundColor: CSSColor?

    public func register(with registry: JXRegistry) throws {
    }

    private var observers: [AnyObject] = []

    deinit {
        // clear circular references
        observers.removeAll()
    }

    // MARK: UIKit-specific properties
    #if canImport(UIKit)
    static var navBar: UINavigationBar { UINavigationBar.appearance() }

    @Pack public var navBarTintColor: CSSColor? = navBar.tintColor?.ciColor.cssColor
    static func navBarTintColorDidSet(_ newValue: CSSColor?) {
        navBar.tintColor = newValue?.nativeColor.uiColor
    }

    static var tabBar: UITabBar { UITabBar.appearance() }

    @Pack public var tabBarTintColor: CSSColor? = tabBar.tintColor?.ciColor.cssColor
    static func tabBarTintColorDidSet(_ newValue: CSSColor?) {
        tabBar.tintColor = newValue?.nativeColor.uiColor
    }

    static var label: UILabel { UILabel.appearance() }

    @Pack public var labelTintColor: CSSColor? = label.tintColor?.ciColor.cssColor
    static func labelTintColorDidSet(_ newValue: CSSColor?) {
        label.tintColor = newValue?.nativeColor.uiColor
    }


    func setupListeners() {
        observers += [
            $navBarTintColor.sink(receiveValue: Self.navBarTintColorDidSet),
            $tabBarTintColor.sink(receiveValue: Self.tabBarTintColorDidSet),
            $labelTintColor.sink(receiveValue: Self.labelTintColorDidSet),
            //$navBarTintColor.sink(receiveValue: { [weak self] _ in }),
            ]
    }

    #else

    //static var textField: NSTextField { NSTextField.appearance }

    func setupListeners() {
        // TODO: AppKit
    }

    #endif
}

// MARK: UIKit-specific properties

#if canImport(UIKit)
import UIKit

extension ThemePod {

}

#endif

// MARK: AppKit-specific properties

#if canImport(AppKit)
import AppKit

extension ThemePod {

}
#endif


// public struct ThemeColor = XOr<RGBColor>.Or<HSLColor>.Or<ParsedCSSColor>


/**
 ## Formal syntax

 from https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#formal_syntax

 ```
 <color> =
 <absolute-color-base>  |
 currentcolor           |
 <system-color>

 <absolute-color-base> =
 <hex-color>                |
 <absolute-color-function>  |
 <named-color>              |
 transparent

 <absolute-color-function> =
 <rgb()>    |
 <rgba()>   |
 <hsl()>    |
 <hsla()>   |
 <hwb()>    |
 <lab()>    |
 <lch()>    |
 <oklab()>  |
 <oklch()>  |
 <color()>

 <rgb()> =
 rgb( [ <percentage> | none ]{3} [ / [ <alpha-value> | none ] ]? )  |
 rgb( [ <number> | none ]{3} [ / [ <alpha-value> | none ] ]? )

 <hsl()> =
 hsl( [ <hue> | none ] [ <percentage> | none ] [ <percentage> | none ] [ / [ <alpha-value> | none ] ]? )

 <hwb()> =
 hwb( [ <hue> | none ] [ <percentage> | none ] [ <percentage> | none ] [ / [ <alpha-value> | none ] ]? )

 <lab()> =
 lab( [ <percentage> | <number> | none ] [ <percentage> | <number> | none ] [ <percentage> | <number> | none ] [ / [ <alpha-value> | none ] ]? )

 <lch()> =
 lch( [ <percentage> | <number> | none ] [ <percentage> | <number> | none ] [ <hue> | none ] [ / [ <alpha-value> | none ] ]? )

 <oklab()> =
 oklab( [ <percentage> | <number> | none ] [ <percentage> | <number> | none ] [ <percentage> | <number> | none ] [ / [ <alpha-value> | none ] ]? )

 <oklch()> =
 oklch( [ <percentage> | <number> | none ] [ <percentage> | <number> | none ] [ <hue> | none ] [ / [ <alpha-value> | none ] ]? )

 <color()> =
 color( <colorspace-params> [ / [ <alpha-value> | none ] ]? )

 <alpha-value> =
 <number>      |
 <percentage>

 <hue> =
 <number>  |
 <angle>   |
 none

 <colorspace-params> =
 <predefined-rgb-params>  |
 <xyz-params>

 <predefined-rgb-params> =
 <predefined-rgb> [ <number> | <percentage> | none ]{3}

 <xyz-params> =
 <xyz-space> [ <number> | <percentage> | none ]{3}

 <predefined-rgb> =
 srgb          |
 srgb-linear   |
 display-p3    |
 a98-rgb       |
 prophoto-rgb  |
 rec2020

 <xyz-space> =
 xyz      |
 xyz-d50  |
 xyz-d65
 ```
 */
public struct CSSColor : Codable, Hashable, CustomStringConvertible {
    public var rep: ColorRepresentation

    /// Create this color with a CSS named color
    public init(name color: NamedColor) {
        self.rep = .name(color)
    }

    /// Create this color with an RGB description
    public init(rgb color: RGBColor) {
        self.rep = .rgb(color)
    }

    public var description: String {
        switch rep {
        case .name(let name): return name.description
        case .rgb(let color): return color.description
        }
    }

    public enum ColorError : Error {
        case hexStringMissingPercent
        case parseErrors(errors: [Error])
        case hexStringInvalid(string: String)
    }

    public init(from decoder: Decoder) throws {
        do {
            do {
                self.rep = try .name(.init(from: decoder))
            } catch let e1 {
                do {
                    self.rep = try .rgb(.init(from: decoder))
                } catch let e2 {
                    do {
                        let str = try String(from: decoder)
                        self.rep = try .rgb(.parseColor(css: str))
                    } catch let e3 {
                        throw ColorError.parseErrors(errors: [e1, e2, e3])
                    }
                }
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch rep {
        case .name(let x): try container.encode(x)
        case .rgb(let x): try container.encode(x)
            //case .hsl(let x): try container.encode(x)
        }
    }

    public enum ColorRepresentation: Hashable, CustomStringConvertible {
        case name(NamedColor)
        case rgb(RGBColor)
        //case hsl(HSLColor)
        // case hwb(HWBColor) // TODO: maybe someday

        public var description: String {
            switch self {
            case .name(let name): return name.description
            case .rgb(let color): return color.description
            }
        }
    }

    public struct RGBColor : Codable, Hashable, CustomStringConvertible, ExpressibleByIntegerLiteral {
        public var r: Double
        public var g: Double
        public var b: Double
        public var a: Double?

        public init(r: Double, g: Double, b: Double, a: Double? = nil) {
            self.r = r
            self.g = g
            self.b = b
            self.a = a
        }

        /// Create from a single integer like 0x55AA11FF
        public init(integerLiteral value: IntegerLiteralType) {
            let r = (value & 0xFF0000) >> 16
            let g = (value & 0x00FF00) >> 8
            let b = (value & 0x0000FF) >> 0

            self.init(r: CGFloat(r) / 255, g: CGFloat(g) / 255, b: CGFloat(b) / 255, a: 1.0)
        }

        public static func parseColor(css: String) throws -> RGBColor {
            return try parseHexColor(css: css)
        }

        public var description: String {
            "#" + ([r, g, b, a].compactMap({ $0 }).map { c in
                String(format: "%02X", Int(c * 255.0))
            }).joined()
        }

        public static func parseHexColor(css: String) throws -> RGBColor {
            guard css.first == "#" else {
                throw ColorError.hexStringMissingPercent
            }
            let chars = Array(css.dropFirst(1))

            func parse(_ str: ArraySlice<Character>) throws -> Double {
                guard let i = Int(String(str), radix: 16) else {
                    throw ColorError.hexStringInvalid(string: String(str))
                }
                return Double(i) / 255.0
            }

            switch chars.count {
            case 3: // #A1B
                return try RGBColor(r: parse(chars[0...0]), g: parse(chars[1...1]), b: parse(chars[2...2]))
            case 4: // #A1B0
                return try RGBColor(r: parse(chars[0...0]), g: parse(chars[1...1]), b: parse(chars[2...2]), a: parse(chars[3...3]))
            case 6: // #AB1122
                return try RGBColor(r: parse(chars[0...1]), g: parse(chars[2...3]), b: parse(chars[4...5]))
            case 8: // #AB1122FF
                return try RGBColor(r: parse(chars[0...1]), g: parse(chars[2...3]), b: parse(chars[4...5]), a: parse(chars[6...7]))

            default:
                throw ColorError.hexStringInvalid(string: css)
            }

            //
            //            func parseColor(_ r: String, _ g: String, _ b: String, _ a: String = "0xFF") -> (Double, Double, Double, Double) {
            //                (coerce(r) ?? 0.5, coerce(g) ?? 0.5, coerce(b) ?? 0.5, coerce(a) ?? 1.0)
            //            }

        }
    }

    //    public struct HSLColor : Codable, Hashable {
    //        var h: Double
    //        var s: Double
    //        var l: Double
    //        var a: Double?
    //    }

    public struct NamedColor : Codable, Hashable, RawRepresentable, CaseIterable, CustomStringConvertible {
        public var name: String
        public var color: RGBColor

        // named colors from: https://developer.mozilla.org/en-US/docs/Web/CSS/named-color

        public init(name: String, color: RGBColor) {
            self.name = name
            self.color = color
        }

        public var description: String {
            "\"" + name + "\""
        }

        public init?(rawValue: String) {
            let str = rawValue.lowercased()
            for namedColor in Self.allCases {
                if str == namedColor.name {
                    self = namedColor
                    return
                }
            }

            return nil
        }

        public var rawValue: String {
            name
        }

        public static var allCases: [NamedColor] {
            [
                transparent,
                black,
                silver,
                gray,
                white,
                maroon,
                red,
                purple,
                fuchsia,
                green,
                lime,
                olive,
                yellow,
                navy,
                blue,
                teal,
                aqua,
                orange,
                aliceblue,
                antiquewhite,
                aquamarine,
                azure,
                beige,
                bisque,
                blanchedalmond,
                blueviolet,
                brown,
                burlywood,
                cadetblue,
                chartreuse,
                chocolate,
                coral,
                cornflowerblue,
                cornsilk,
                crimson,
                cyan,
                darkblue,
                darkcyan,
                darkgoldenrod,
                darkgray,
                darkgreen,
                darkgrey,
                darkkhaki,
                darkmagenta,
                darkolivegreen,
                darkorange,
                darkorchid,
                darkred,
                darksalmon,
                darkseagreen,
                darkslateblue,
                darkslategray,
                darkslategrey,
                darkturquoise,
                darkviolet,
                deeppink,
                deepskyblue,
                dimgray,
                dimgrey,
                dodgerblue,
                firebrick,
                floralwhite,
                forestgreen,
                gainsboro,
                ghostwhite,
                gold,
                goldenrod,
                greenyellow,
                grey,
                honeydew,
                hotpink,
                indianred,
                indigo,
                ivory,
                khaki,
                lavender,
                lavenderblush,
                lawngreen,
                lemonchiffon,
                lightblue,
                lightcoral,
                lightcyan,
                lightgoldenrodyellow,
                lightgray,
                lightgreen,
                lightgrey,
                lightpink,
                lightsalmon,
                lightseagreen,
                lightskyblue,
                lightslategray,
                lightslategrey,
                lightsteelblue,
                lightyellow,
                limegreen,
                linen,
                magenta,
                mediumaquamarine,
                mediumblue,
                mediumorchid,
                mediumpurple,
                mediumseagreen,
                mediumslateblue,
                mediumspringgreen,
                mediumturquoise,
                mediumvioletred,
                midnightblue,
                mintcream,
                mistyrose,
                moccasin,
                navajowhite,
                oldlace,
                olivedrab,
                orangered,
                orchid,
                palegoldenrod,
                palegreen,
                paleturquoise,
                palevioletred,
                papayawhip,
                peachpuff,
                peru,
                pink,
                plum,
                powderblue,
                rosybrown,
                royalblue,
                saddlebrown,
                salmon,
                sandybrown,
                seagreen,
                seashell,
                sienna,
                skyblue,
                slateblue,
                slategray,
                slategrey,
                snow,
                springgreen,
                steelblue,
                tan,
                thistle,
                tomato,
                turquoise,
                violet,
                wheat,
                whitesmoke,
                yellowgreen,
            ]
        }

        private static func named(_ name: String, _ color: RGBColor) -> NamedColor {
            NamedColor(name: name, color: color)
        }

        public static let transparent = named("transparent", RGBColor(r: 0, g: 0, b: 0, a: 0))

        public static let black = named("black", 0x000000)
        public static let silver = named("silver", 0xc0c0c0)
        public static let gray = named("gray", 0x808080)
        public static let white = named("white", 0xffffff)
        public static let maroon = named("maroon", 0x800000)
        public static let red = named("red", 0xff0000)
        public static let purple = named("purple", 0x800080)
        public static let fuchsia = named("fuchsia", 0xff00ff)
        public static let green = named("green", 0x008000)
        public static let lime = named("lime", 0x00ff00)
        public static let olive = named("olive", 0x808000)
        public static let yellow = named("yellow", 0xffff00)
        public static let navy = named("navy", 0x000080)
        public static let blue = named("blue", 0x0000ff)
        public static let teal = named("teal", 0x008080)
        public static let aqua = named("aqua", 0x00ffff)
        public static let orange = named("orange", 0xffa500)
        public static let aliceblue = named("aliceblue", 0xf0f8ff)
        public static let antiquewhite = named("antiquewhite", 0xfaebd7)
        public static let aquamarine = named("aquamarine", 0x7fffd4)
        public static let azure = named("azure", 0xf0ffff)
        public static let beige = named("beige", 0xf5f5dc)
        public static let bisque = named("bisque", 0xffe4c4)
        public static let blanchedalmond = named("blanchedalmond", 0xffebcd)
        public static let blueviolet = named("blueviolet", 0x8a2be2)
        public static let brown = named("brown", 0xa52a2a)
        public static let burlywood = named("burlywood", 0xdeb887)
        public static let cadetblue = named("cadetblue", 0x5f9ea0)
        public static let chartreuse = named("chartreuse", 0x7fff00)
        public static let chocolate = named("chocolate", 0xd2691e)
        public static let coral = named("coral", 0xff7f50)
        public static let cornflowerblue = named("cornflowerblue", 0x6495ed)
        public static let cornsilk = named("cornsilk", 0xfff8dc)
        public static let crimson = named("crimson", 0xdc143c)
        public static let cyan = named("cyan", 0x00ffff)
        public static let darkblue = named("darkblue", 0x00008b)
        public static let darkcyan = named("darkcyan", 0x008b8b)
        public static let darkgoldenrod = named("darkgoldenrod", 0xb8860b)
        public static let darkgray = named("darkgray", 0xa9a9a9)
        public static let darkgreen = named("darkgreen", 0x006400)
        public static let darkgrey = named("darkgrey", 0xa9a9a9)
        public static let darkkhaki = named("darkkhaki", 0xbdb76b)
        public static let darkmagenta = named("darkmagenta", 0x8b008b)
        public static let darkolivegreen = named("darkolivegreen", 0x556b2f)
        public static let darkorange = named("darkorange", 0xff8c00)
        public static let darkorchid = named("darkorchid", 0x9932cc)
        public static let darkred = named("darkred", 0x8b0000)
        public static let darksalmon = named("darksalmon", 0xe9967a)
        public static let darkseagreen = named("darkseagreen", 0x8fbc8f)
        public static let darkslateblue = named("darkslateblue", 0x483d8b)
        public static let darkslategray = named("darkslategray", 0x2f4f4f)
        public static let darkslategrey = named("darkslategrey", 0x2f4f4f)
        public static let darkturquoise = named("darkturquoise", 0x00ced1)
        public static let darkviolet = named("darkviolet", 0x9400d3)
        public static let deeppink = named("deeppink", 0xff1493)
        public static let deepskyblue = named("deepskyblue", 0x00bfff)
        public static let dimgray = named("dimgray", 0x696969)
        public static let dimgrey = named("dimgrey", 0x696969)
        public static let dodgerblue = named("dodgerblue", 0x1e90ff)
        public static let firebrick = named("firebrick", 0xb22222)
        public static let floralwhite = named("floralwhite", 0xfffaf0)
        public static let forestgreen = named("forestgreen", 0x228b22)
        public static let gainsboro = named("gainsboro", 0xdcdcdc)
        public static let ghostwhite = named("ghostwhite", 0xf8f8ff)
        public static let gold = named("gold", 0xffd700)
        public static let goldenrod = named("goldenrod", 0xdaa520)
        public static let greenyellow = named("greenyellow", 0xadff2f)
        public static let grey = named("grey", 0x808080)
        public static let honeydew = named("honeydew", 0xf0fff0)
        public static let hotpink = named("hotpink", 0xff69b4)
        public static let indianred = named("indianred", 0xcd5c5c)
        public static let indigo = named("indigo", 0x4b0082)
        public static let ivory = named("ivory", 0xfffff0)
        public static let khaki = named("khaki", 0xf0e68c)
        public static let lavender = named("lavender", 0xe6e6fa)
        public static let lavenderblush = named("lavenderblush", 0xfff0f5)
        public static let lawngreen = named("lawngreen", 0x7cfc00)
        public static let lemonchiffon = named("lemonchiffon", 0xfffacd)
        public static let lightblue = named("lightblue", 0xadd8e6)
        public static let lightcoral = named("lightcoral", 0xf08080)
        public static let lightcyan = named("lightcyan", 0xe0ffff)
        public static let lightgoldenrodyellow = named("lightgoldenrodyellow", 0xfafad2)
        public static let lightgray = named("lightgray", 0xd3d3d3)
        public static let lightgreen = named("lightgreen", 0x90ee90)
        public static let lightgrey = named("lightgrey", 0xd3d3d3)
        public static let lightpink = named("lightpink", 0xffb6c1)
        public static let lightsalmon = named("lightsalmon", 0xffa07a)
        public static let lightseagreen = named("lightseagreen", 0x20b2aa)
        public static let lightskyblue = named("lightskyblue", 0x87cefa)
        public static let lightslategray = named("lightslategray", 0x778899)
        public static let lightslategrey = named("lightslategrey", 0x778899)
        public static let lightsteelblue = named("lightsteelblue", 0xb0c4de)
        public static let lightyellow = named("lightyellow", 0xffffe0)
        public static let limegreen = named("limegreen", 0x32cd32)
        public static let linen = named("linen", 0xfaf0e6)
        public static let magenta = named("magenta", 0xff00ff)
        public static let mediumaquamarine = named("mediumaquamarine", 0x66cdaa)
        public static let mediumblue = named("mediumblue", 0x0000cd)
        public static let mediumorchid = named("mediumorchid", 0xba55d3)
        public static let mediumpurple = named("mediumpurple", 0x9370db)
        public static let mediumseagreen = named("mediumseagreen", 0x3cb371)
        public static let mediumslateblue = named("mediumslateblue", 0x7b68ee)
        public static let mediumspringgreen = named("mediumspringgreen", 0x00fa9a)
        public static let mediumturquoise = named("mediumturquoise", 0x48d1cc)
        public static let mediumvioletred = named("mediumvioletred", 0xc71585)
        public static let midnightblue = named("midnightblue", 0x191970)
        public static let mintcream = named("mintcream", 0xf5fffa)
        public static let mistyrose = named("mistyrose", 0xffe4e1)
        public static let moccasin = named("moccasin", 0xffe4b5)
        public static let navajowhite = named("navajowhite", 0xffdead)
        public static let oldlace = named("oldlace", 0xfdf5e6)
        public static let olivedrab = named("olivedrab", 0x6b8e23)
        public static let orangered = named("orangered", 0xff4500)
        public static let orchid = named("orchid", 0xda70d6)
        public static let palegoldenrod = named("palegoldenrod", 0xeee8aa)
        public static let palegreen = named("palegreen", 0x98fb98)
        public static let paleturquoise = named("paleturquoise", 0xafeeee)
        public static let palevioletred = named("palevioletred", 0xdb7093)
        public static let papayawhip = named("papayawhip", 0xffefd5)
        public static let peachpuff = named("peachpuff", 0xffdab9)
        public static let peru = named("peru", 0xcd853f)
        public static let pink = named("pink", 0xffc0cb)
        public static let plum = named("plum", 0xdda0dd)
        public static let powderblue = named("powderblue", 0xb0e0e6)
        public static let rosybrown = named("rosybrown", 0xbc8f8f)
        public static let royalblue = named("royalblue", 0x4169e1)
        public static let saddlebrown = named("saddlebrown", 0x8b4513)
        public static let salmon = named("salmon", 0xfa8072)
        public static let sandybrown = named("sandybrown", 0xf4a460)
        public static let seagreen = named("seagreen", 0x2e8b57)
        public static let seashell = named("seashell", 0xfff5ee)
        public static let sienna = named("sienna", 0xa0522d)
        public static let skyblue = named("skyblue", 0x87ceeb)
        public static let slateblue = named("slateblue", 0x6a5acd)
        public static let slategray = named("slategray", 0x708090)
        public static let slategrey = named("slategrey", 0x708090)
        public static let snow = named("snow", 0xfffafa)
        public static let springgreen = named("springgreen", 0x00ff7f)
        public static let steelblue = named("steelblue", 0x4682b4)
        public static let tan = named("tan", 0xd2b48c)
        public static let thistle = named("thistle", 0xd8bfd8)
        public static let tomato = named("tomato", 0xff6347)
        public static let turquoise = named("turquoise", 0x40e0d0)
        public static let violet = named("violet", 0xee82ee)
        public static let wheat = named("wheat", 0xf5deb3)
        public static let whitesmoke = named("whitesmoke", 0xf5f5f5)
        public static let yellowgreen = named("yellowgreen", 0x9acd32)
    }
}

#if canImport(CoreImage)

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
extension CIColor {
    var uiColor: NSColor {
        NSColor(ciColor: self)
    }
}
#elseif canImport(UIKit)
extension CIColor {
    var uiColor: UIColor {
        UIColor(ciColor: self)
    }
}
#endif


extension CIColor {
    /// Converts this color into a CSSColor
    var cssColor: CSSColor {
        CSSColor(nativeColor: self)
    }
}

extension CSSColor {
    /// Creates this `CSSColor` from a native CoreImage ``CIColor``.`
    public init(nativeColor: CIColor) {
        self.init(rgb: RGBColor(r: nativeColor.red, g: nativeColor.green, b: nativeColor.blue, a: nativeColor.alpha))
    }
}

public extension CSSColor {
    var nativeColor: CIColor {
        switch self.rep {
        case .name(let color): return color.color.nativeColor
        case .rgb(let color): return color.nativeColor
            //case .hsl(let color): return color.nativeColor
        }

        // TODO: system colors?
        // return CIColor.pink
        // return UIColor.systemPink / NSColor.systemPink
    }
}

public extension CSSColor.RGBColor {
    var nativeColor: CIColor {
        CIColor(red: self.r, green: self.g, blue: self.b, alpha: self.a ?? 1.0)
    }
}
#endif


