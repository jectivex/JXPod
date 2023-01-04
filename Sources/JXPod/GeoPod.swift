import Foundation
import JXBridge


// MARK: GeoPod

public protocol GeoPod : JXPod, JXModule, JXBridging {
    func currentLocation() async throws -> Location
}

/// A location on earth.
public struct Location : Codable, Equatable {
    public var latitude: Double
    public var longitude: Double
    public var altitude: Double
}


// MARK: CoreLocationGeoPod

// await location.current()

#if canImport(CoreLocation)
import CoreLocation

open class CoreLocationGeoPod : NSObject, CLLocationManagerDelegate, GeoPod {
    public let namespace: JXNamespace = "net"
    private let manager: CLLocationManager

    //@Stack var locations: [Location] = []

    public init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
        manager.delegate = self
    }

    public static var metadata: JXPodMetaData {
        JXPodMetaData(source: URL(string: "https://github.com/jectivex/JXPod.git")!)
    }

    public func register(with registry: JXRegistry) throws {
        try registry.registerBridge(for: self, namespace: namespace)
    }

    public func currentLocation() async throws -> Location {
        manager.requestLocation()
        // TODO: handle responses in delegate
        return try await withCheckedThrowingContinuation { c in
            c.resume(throwing: CocoaError(.featureUnsupported))
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }

}
#endif


