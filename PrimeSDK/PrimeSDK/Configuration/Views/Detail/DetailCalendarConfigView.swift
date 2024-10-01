import Foundation
import SwiftyJSON

class DetailCalendarConfigView: ConfigView {
    struct Attributes {
        var notificationText: String
        var addToCalendarText: String
        var noEventText: String

        init(json: JSON) {
            notificationText = json["notification_text"].stringValue
            addToCalendarText = json["add_to_calendar_text"].stringValue
            noEventText = json["no_event_text"].stringValue
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
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])
        super.init(json: json)
    }
}
