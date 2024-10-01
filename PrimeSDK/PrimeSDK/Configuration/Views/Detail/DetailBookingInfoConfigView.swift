import Foundation
import SwiftyJSON

class DetailBookingInfoConfigView: ConfigView {
    struct Actions {
        var load: String?

        init(json: JSON) {
            self.load = json["load"].string
        }
    }
    var actions: Actions

    override init(json: JSON) {
        self.actions = Actions(json: json["actions"])

        super.init(json: json)
    }
}
