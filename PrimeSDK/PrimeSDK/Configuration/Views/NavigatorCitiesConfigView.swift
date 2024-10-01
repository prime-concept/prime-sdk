import Foundation
import SwiftyJSON

class NavigatorCitiesConfigView: ConfigView {
    struct Attributes {
        var supportPagination: Bool
        var title: String?

        init(json: JSON) {
            self.supportPagination = json["support_pagination"].boolValue
            self.title = json["title"].string
        }
    }
    var attributes: Attributes

    struct Actions {
        var load: String
        var tap: String

        init(json: JSON) {
            self.load = json["load"].stringValue
            self.tap = json["tap"].stringValue
        }
    }
    var actions: Actions

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])
        super.init(json: json)
    }
}
