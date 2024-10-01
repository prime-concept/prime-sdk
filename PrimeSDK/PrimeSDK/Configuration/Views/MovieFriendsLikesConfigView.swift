import Foundation
import SwiftyJSON

class MovieFriendsLikesConfigView: ConfigView {
    struct Attributes {
        var title: String

        init(json: JSON) {
            self.title = json["title"].stringValue
        }
    }
    var attributes: Attributes

    struct Actions {
        var load: String?
        var share: String?
        var toggleFavorite: String?

        init(json: JSON) {
            load = json["load"].string
            share = json["share"].string
            toggleFavorite = json["toggle_favorite"].string
        }
    }
    var actions: Actions

    override init(json: JSON) {
        actions = Actions(json: json["actions"])
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
