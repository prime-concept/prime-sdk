import Foundation
import SwiftyJSON

class DetailScheduleConfigView: ConfigView {
    struct Attributes {
        var title: String

        var mondayTitle: String
        var tuesdayTitle: String
        var wednesdayTitle: String
        var thursdayTitle: String
        var fridayTitle: String
        var saturdayTitle: String
        var sundayTitle: String

        var closeUntilTitle: String
        var openUntilTitle: String

        var closedTitle: String
        var openedTitle: String

        var showButtonTitle: String
        var hideButtonTitle: String
        var buttonTitleColor: String?

        init(json: JSON) {
            self.title = json["title"].stringValue

            self.mondayTitle = json["monday_title"].stringValue
            self.tuesdayTitle = json["tuesday_title"].stringValue
            self.wednesdayTitle = json["wednesday_title"].stringValue
            self.thursdayTitle = json["thursday_title"].stringValue
            self.fridayTitle = json["friday_title"].stringValue
            self.saturdayTitle = json["saturday_title"].stringValue
            self.sundayTitle = json["sunday_title"].stringValue

            self.closeUntilTitle = json["close_until_title"].stringValue
            self.openUntilTitle = json["open_until_title"].stringValue
            self.closedTitle = json["closed_title"].stringValue
            self.openedTitle = json["opened_title"].stringValue

            self.showButtonTitle = json["button_title"].stringValue
            self.hideButtonTitle = json["hide_button_title"].stringValue
            self.buttonTitleColor = json["button_title_color"].string
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
