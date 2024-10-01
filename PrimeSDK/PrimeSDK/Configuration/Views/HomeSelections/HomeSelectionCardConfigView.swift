import Foundation
import SwiftyJSON

class HomeSelectionCardConfigView: ConfigView {
    struct Attributes {
        var title: String?
        var subtitle: String?
        var imagePath: String?
        var id: String

        init(json: JSON) {
            self.id = json["id"].stringValue
            self.title = json["title"].string
            self.subtitle = json["subtitle"].string
            self.imagePath = json["image_path"].string
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
        actions = Actions(json: json["actions"])
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
