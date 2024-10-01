import Foundation
import SwiftyJSON

class ListConfigView: ConfigView {
    var subviews: [String]

    struct Attributes {
        var supportPagination: Bool
        var hasHeader: Bool
        var allowsLocation: Bool
        var itemHeight: Float?
        var allowsPullToRefresh: Bool = true
        var supportAutoItemHeight: Bool = false
        var shouldHideScrollIndicator: Bool = false

        init(json: JSON) {
            self.supportPagination = json["support_pagination"].boolValue
            self.hasHeader = json["has_header"].boolValue
            self.allowsLocation = json["allow_location"].boolValue
            self.itemHeight = json["item_height"].float
            self.allowsPullToRefresh = json["allow_pull_to_refresh"].bool ?? self.allowsPullToRefresh
            self.supportAutoItemHeight = json["support_auto_item_height"].bool ?? self.supportAutoItemHeight
            self.shouldHideScrollIndicator = json["should_hide_scroll_indicator"].bool ?? self.shouldHideScrollIndicator
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
        subviews = json["supported_cells"].arrayObject as? [String] ?? []
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])
        super.init(json: json)
    }
}
