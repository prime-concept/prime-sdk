import Foundation
import SwiftyJSON

class CinemaCardConfigView: ConfigView {
    struct Attributes {
        var title: String

        init(json: JSON) {
            self.title = json["title"].stringValue
        }
    }
    var attributes: Attributes

    struct Actions {
        var tap: String?
        var toggleFavorite: String?

        init(json: JSON) {
            tap = json["tap"].string
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
