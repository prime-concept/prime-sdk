import Foundation
import SwiftyJSON

class NavigatorHomeImageConfigView: ConfigView {
    struct Attributes {
        var height: Float
        var width: String
        var image: String
        var title: String

        init(json: JSON) {
            self.height = json["height"].floatValue
            self.width = json["width"].stringValue
            self.image = json["image"].stringValue
            self.title = json["title"].stringValue
        }
    }
    var attributes: Attributes

    struct Actions {
        var tap: String
        init(json: JSON) {
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
