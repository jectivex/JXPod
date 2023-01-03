import Foundation
import JXBridge

// MARK: ChartPod

#if canImport(Charts)
import Charts

open class ChartPod : JXPod, JXModule {
    public let namespace: JXNamespace = "chart"

    public init() {
    }

    public var metadata: JXPodMetaData {
        JXPodMetaData(homePage: URL(string: "https://www.example.com")!)
    }

    public func register(with registry: JXRegistry) throws {
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

#endif
