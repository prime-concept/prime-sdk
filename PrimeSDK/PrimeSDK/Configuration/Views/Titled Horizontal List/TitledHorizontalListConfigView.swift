import Foundation
import SwiftyJSON

class TitledHorizontalListConfigView: ConfigView {
    var subviews: [String]

    struct Attributes {
        var itemHeight: Float
        var itemWidth: Float
        var spacing: Float
        var title: String
        var showTitle: Bool = true
        var showAll: Bool = true
        var titleColor: String = "#000000"
        var allColor: String = "#0080ff"
        var sideInsets: Float = 15

        init(json: JSON) {
            self.itemHeight = json["item_height"].floatValue
            self.itemWidth = json["item_width"].floatValue
            self.spacing = json["spacing"].floatValue
            self.title = json["title"].stringValue
            self.showTitle = json["show_title"].bool ?? self.showTitle
            self.showAll = json["show_all"].bool ?? self.showAll
            self.titleColor = json["title_color"].string ?? self.titleColor
            self.allColor = json["all_color"].string ?? self.allColor
            self.sideInsets = json["side_insets"].float ?? self.sideInsets
        }
    }
    var attributes: Attributes

    struct Actions {
        var load: String
        var tapAll: String

        init(json: JSON) {
            self.load = json["load"].stringValue
            self.tapAll = json["tap_all"].stringValue
        }
    }
    var actions: Actions

    override init(json: JSON) {
        subviews = json["subviews"].arrayObject as? [String] ?? []
        actions = Actions(json: json["actions"])
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
