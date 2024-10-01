import Foundation
import SwiftyJSON

class DetailLocationConfigView: ConfigView {
    struct Attributes {
        var title: String
        var taxiTitle: String
        var taxiPrice: Int?
        var taxiUrl: String?
        var lat: Double?
        var lon: Double?
        var address: String?
        var priceEndingTitle: String
        var fromTitle: String

        init(json: JSON) {
            self.title = json["title"].stringValue
            self.taxiTitle = json["taxi_title"].stringValue
            self.taxiUrl = json["url"].string
            self.taxiPrice = json["price"].int
            self.lat = json["lat"].double
            self.lon = json["lon"].double
            self.address = json["address"].string
            self.priceEndingTitle = json["price_ending_title"].stringValue
            self.fromTitle = json["from"].stringValue
        }
    }

    var attributes: Attributes

    struct Actions {
        var load: String
        init(json: JSON) {
            self.load = json["load"].stringValue
        }
    }
    var actions: Actions

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])

        super.init(json: json)
    }
}
