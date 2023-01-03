//import Foundation
//import Jack
//
//
//// MARK: ConsolePod
//
//public protocol ConsolePod : JackPod {
//}
//
//// console.log('message…')
//
///// A ``ConsolePod`` that stores messages in a buffer
//open class CapturingConsolePod : JackPod, ConsolePod {
//    public var metadata: JackPodMetaData {
//        JackPodMetaData(homePage: URL(string: "https://www.example.com")!)
//    }
//}
//
//#if canImport(OSLog)
//import OSLog
//
///// A ``ConsolePod`` that forwards logged messages to the system consle
//open class OSLogConsolePod : JackPod, ConsolePod {
//    open var metadata: JackPodMetaData {
//        JackPodMetaData(homePage: URL(string: "https://www.example.com")!)
//    }
//
//
//    public init() {
//    }
//}
//#endif
//
