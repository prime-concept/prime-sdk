import Foundation
import SwiftyJSON

class DetailRoutePlacesConfigView: ConfigView {
    struct Attributes {
        var startRoute: String
        var endRoute: String

        init(json: JSON) {
            startRoute = json["start_route_text"].stringValue
            endRoute = json["end_route_text"].stringValue
        }
    }
    var attributes: Attributes
    var item: String

    override init(json: JSON) {
        item = json["item"].stringValue
        attributes = Attributes(json: json["attributes"])
        super.init(json: json)
    }
}
