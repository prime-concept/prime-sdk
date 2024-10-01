import CoreLocation
import Foundation
import SwiftyJSON

public final class GeoCoordinate: Equatable {
    public var latitude: Double
    public var longitude: Double

    public init?(json: JSON) {
        guard let lat = json["lat"].double,
            let lng = json["lng"].double else {
                return nil
        }

        self.latitude = lat
        self.longitude = lng
    }

    public init(lat: Double, lng: Double) {
        self.latitude = lat
        self.longitude = lng
    }

    public var headerFields: [String: String] {
        return [
            "X-User-Latitude": "\(latitude)",
            "X-User-Longitude": "\(longitude)"
        ]
    }

    public init(location: CLLocationCoordinate2D) {
        self.latitude = location.latitude
        self.longitude = location.longitude
    }

    public var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public static func == (lhs: GeoCoordinate, rhs: GeoCoordinate) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    public func latLongString() -> String {
        return "\(latitude),\(longitude)"
    }
}

extension CLLocationCoordinate2D {
    public init(geoCoordinates: GeoCoordinate) {
        self.init(
            latitude: geoCoordinates.latitude,
            longitude: geoCoordinates.longitude
        )
    }
}

extension CLLocation {
    public convenience init(geoCoordinates: GeoCoordinate) {
        self.init(
            latitude: geoCoordinates.latitude,
            longitude: geoCoordinates.longitude
        )
    }
}
