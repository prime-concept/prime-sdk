import Foundation
import SwiftyJSON

class FilterItemConfigView: ConfigView {
    struct Attributes {
        var id: String
        var title: String

        init(json: JSON) {
            self.id = json["id"].stringValue
            self.title = json["title"].stringValue
        }
    }

    struct Actions {
        var tap: String

        init(json: JSON) {
            self.tap = json["tap"].stringValue
        }
    }

    var attributes: Attributes
    var actions: Actions

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])

        super.init(json: json)
    }
}
