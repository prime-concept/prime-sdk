import Foundation
import SwiftyJSON

class DetailMapConfigView: ConfigView {
    struct Attributes {
        var lat: Double?
        var lon: Double?
        var address: String?
        var metro: String?

        init(json: JSON) {
            self.lat = json["lat"].double
            self.lon = json["lon"].double
            self.address = json["address"].string
            self.metro = json["metro"].string
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
