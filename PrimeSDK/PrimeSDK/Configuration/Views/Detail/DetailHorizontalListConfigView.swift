import Foundation
import SwiftyJSON

class DetailHorizontalListConfigView: ConfigView {
    var item: String

    struct Attributes {
        var title: String
        var allowsLocation: Bool = false
        var itemWidth: Float?
        var itemHeight: Float?
        var overlapDelta: Float?

        init(json: JSON) {
            self.title = json["title"].stringValue
            self.allowsLocation = json["allow_location"].bool ?? allowsLocation
            self.itemHeight = json["item_height"].float
            self.itemWidth = json["item_width"].float
            self.overlapDelta = json["overlap_delta"].float
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
