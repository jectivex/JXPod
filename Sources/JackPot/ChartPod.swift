import Foundation
import Jack

// MARK: ChartPod

#if canImport(Charts)
import Charts

open class ChartPod : JackPod {
    public init() {
    }

    public var metadata: JackPodMetaData {
        JackPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

//    @Jack("Divider") var _divider = divider
//    func divider() -> ChartTemplate {
//        class DividerTemplate : ChartTemplate {
////            override var anyView: AnyView { AnyView(body) }
////            public var body: some View { Divider() }
//        }
//        return DividerTemplate()
//    }
}

@available(macOS 13, macCatalyst 16, iOS 16, tvOS 16, watchOS 9, *)
public protocol JackedChart : JackedReference {
    var anyChart: AnyChartContent { get }
    var childCharts: [JackedChart]? { get }
}

@available(macOS 13, macCatalyst 16, iOS 16, tvOS 16, watchOS 9, *)
open class ChartBuilder : JackedReference, JackedChart {
    @Stack var chartConfig: ChartConfig = ChartConfig()

    @available(macOS 13, macCatalyst 16, iOS 16, tvOS 16, watchOS 9, *)
    open var anyChart: AnyChartContent {
        //dump(AnyChartContent(ChartConfig.applyConfig(Plot(content: { }))), name: "warning: abstract method: \(type(of: self)) \(#function)")
        fatalError("abstract method")
    }

    open var childCharts: [JackedChart]? {
        nil
    }

    @Jack("opacity") var _opacity = opacity
    func opacity(_ value: Double?) -> Self {
        self.chartConfig.opacity = value
        return self
    }

    public struct ChartConfig : Codable, JXConvertible {
        /// The opacity of the chart element
        public var opacity: Double?

        func applyConfig<V: ChartContent>(_ view: V) -> some ChartContent {
            @ChartContentBuilder func withChoice<V1: ChartContent, V2: ChartContent, Value>(_ value: Value?, view: V1, apply: @escaping (Value) -> (V2)) -> some ChartContent {
                if let value = value {
                    apply(value)
                } else {
                    view
                }
            }

            @ChartContentBuilder func withOpacity<V: ChartContent>(_ v: V) -> some ChartContent {
                withChoice(opacity, view: v, apply: v.opacity)
            }

            return withOpacity(view)
        }
    }
}

#endif
