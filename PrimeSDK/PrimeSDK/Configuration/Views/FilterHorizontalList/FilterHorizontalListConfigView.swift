import Foundation
import SwiftyJSON

class FilterHorizontalListConfigView: ConfigView {
    struct Filters {
        struct FilterItem {
            let id: String
            let title: String
            let action: String

            init(json: JSON) {
                self.id = json["id"].stringValue
                self.title = json["title"].stringValue
                self.action = json["action"].stringValue
            }
        }

        var data: [String: Any]

        init(json: JSON) {
            self.data = json.dictionaryObject ?? [:]
        }
    }

    struct Attributes {
        var itemHeight: Float
        var spacing: Float
        var title: String
        var showTitle: Bool

        init(json: JSON) {
            self.itemHeight = json["item_height"].floatValue
            self.spacing = json["spacing"].floatValue
            self.title = json["title"].stringValue
            self.showTitle = json["show_title"].boolValue
        }
    }

    var attributes: Attributes
    var subviews: [String]

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        subviews = json["subviews"].arrayObject as? [String] ?? []

        super.init(json: json)
    }
}
