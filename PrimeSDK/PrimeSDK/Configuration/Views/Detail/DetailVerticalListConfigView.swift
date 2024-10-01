import Foundation
import SwiftyJSON

class DetailVerticalListConfigView: ConfigView {
    var item: String

    struct Attributes {
        var title: String
        var allowsLocation: Bool = false
        var itemHeight: Float?

        init(json: JSON) {
            self.title = json["title"].stringValue
            self.allowsLocation = json["allow_location"].bool ?? allowsLocation
            self.itemHeight = json["item_height"].float
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
        item = json["item"].stringValue
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])
        super.init(json: json)
    }
}
