import Foundation
import JXBridge

// MARK: ChartPod

#if canImport(Charts)
import Charts

open class ChartPod : JXPod, JXModule, JXBridging {
    public let namespace: JXNamespace = "chart"
    public var jxState: JXState?

    public init() {
    }

    public static var metadata: JXPodMetaData {
        JXPodMetaData(source: URL(string: "https://github.com/jectivex/JXPod.git")!)
    }

    public func register(with registry: JXRegistry) throws {
        try registry.registerBridge(for: self, namespace: namespace)
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
