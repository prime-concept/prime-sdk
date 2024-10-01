import Foundation
import GoogleMaps

enum MapHelper {
    static func mapBounds(including coordinates: [CLLocationCoordinate2D]) -> GMSCoordinateBounds {
        var bounds = GMSCoordinateBounds()
        for coordinate in coordinates {
            bounds = bounds.includingCoordinate(coordinate)
        }
        return bounds
    }

    static func mapBounds(
        including coordinates: [CLLocationCoordinate2D],
        paths: [GMSPath]
    ) -> GMSCoordinateBounds {
        var bounds = MapHelper.mapBounds(including: coordinates)
        for path in paths {
            bounds = bounds.includingPath(path)
        }
        return bounds
    }
}
