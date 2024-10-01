import Foundation
import SwiftyJSON

class DetailRouteMapConfigView: ConfigView {
    struct Actions {
        var load: String
        init(json: JSON) {
            self.load = json["load"].stringValue
        }
    }
    var actions: Actions

    override init(json: JSON) {
        actions = Actions(json: json["actions"])
        super.init(json: json)
    }
}
