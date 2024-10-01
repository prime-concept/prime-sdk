import Foundation

struct CinemaAddressViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    var viewName: String

    var title: String
    var coordinate: GeoCoordinate?
    var mall: String
    var address: String
    var distance: Int?
    var subway: Subway?

    var distanceString: String? {
        if
            let distance = distance,
            distance != 0
        {
            return FormatterHelper.format(distanceInMeters: Double(distance))
        } else {
            return nil
        }
    }

    var attributes: [String: Any] {
        return [:]
    }

    let detailRow = DetailRow.cinemaAddress

    init?(
        viewName: String,
        valueForAttributeID: [String: Any]
    ) {
        self.viewName = viewName
        self.title = valueForAttributeID["title"] as? String ?? ""
        self.mall = valueForAttributeID["mall"] as? String ?? ""
        self.address = valueForAttributeID["address"] as? String ?? ""
        if let distanceString = valueForAttributeID["distance"] as? String {
            self.distance = Int(distanceString)
        }

        if
            let latString = valueForAttributeID["latitude"] as? String,
            let lat = Double(latString),
            let lngString = valueForAttributeID["longitude"] as? String,
            let lng = Double(lngString)
        {
            self.coordinate = GeoCoordinate(lat: lat, lng: lng)
        }

        self.subway = Subway(
            valueForAttributeID: CinemaAddressViewModel.getValuesForSubview(
                valueForAttributeID: valueForAttributeID,
                subviewName: "subway"
            )
        )
    }
}
