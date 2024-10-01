import Foundation
import SwiftyJSON

class KinohodSearchConfigView: ConfigView {
    struct Attributes {
        var cinema: String
        var movie: String

        init(json: JSON) {
            self.cinema = json["cinema"].stringValue
            self.movie = json["movie"].stringValue
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
        actions = Actions(json: json["actions"])
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
