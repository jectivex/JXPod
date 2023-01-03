//import Foundation
//import Jack
//
//// MARK: NetPod
//
//// fetch('https://example.org/resource.json')
//
//#if canImport(Foundation)
//
//#if canImport(FoundationNetworking)
//import FoundationNetworking
//#endif
//
//open class NetPod : JackPod {
//    private let session: URLSession
//
//    public init(session: URLSession = .shared) {
//        self.session = session
//    }
//
//    public var metadata: JackPodMetaData {
//        JackPodMetaData(homePage: URL(string: "https://www.example.com")!)
//    }
//
//    // TODO
//    func fetch(url: String) async throws -> Bool {
//        false
//    }
//
//}
//#endif
//
