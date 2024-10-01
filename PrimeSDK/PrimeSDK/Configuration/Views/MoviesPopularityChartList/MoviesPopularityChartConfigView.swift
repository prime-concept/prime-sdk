import Foundation
import SwiftyJSON

class MoviesPopularityChartConfigView: ConfigView {
    var subviews: [String]

    struct Attributes {
        var itemHeight: Float
        var title: String
        var showTitle: Bool = true

        init(json: JSON) {
            self.itemHeight = json["item_height"].floatValue
            self.title = json["title"].stringValue
            self.showTitle = json["show_title"].bool ?? self.showTitle
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
        subviews = json["subviews"].arrayObject as? [String] ?? []
        actions = Actions(json: json["actions"])
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
