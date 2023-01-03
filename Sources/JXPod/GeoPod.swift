//import Foundation
//import Jack
//
//
//// MARK: GeoPod
//
//public protocol GeoPod : JackPod {
//    func currentLocation() async throws -> Location
//}
//
///// A location on earth.
//public struct Location : Codable, Equatable, JXConvertible {
//    public var latitude: Double
//    public var longitude: Double
//    public var altitude: Double
//}
//
//
//// MARK: CoreLocationGeoPod
//
//// await location.current()
//
//#if canImport(CoreLocation)
//import CoreLocation
//
//open class CoreLocationGeoPod : NSObject, CLLocationManagerDelegate, GeoPod {
//    private let manager: CLLocationManager
//
//    @Stack var locations: [Location] = []
//
//    public init(manager: CLLocationManager = CLLocationManager()) {
//        self.manager = manager
//        super.init()
//        manager.delegate = self
//    }
//
//    public var metadata: JackPodMetaData {
//        JackPodMetaData(homePage: URL(string: "https://www.example.com")!)
//    }
//
//    public func currentLocation() async throws -> Location {
//        manager.requestLocation()
//        // TODO: handle responses in delegate
//        return try await withCheckedThrowingContinuation { c in
//            c.resume(throwing: CocoaError(.featureUnsupported))
//        }
//    }
//
//    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//    }
//
//}
//#endif
//
//
