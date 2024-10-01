import Foundation
import SwiftyJSON

class DetailShareConfigView: ConfigView {
    struct Attributes {
        var title: String
        var buttonTitle: String

        init(json: JSON) {
            self.title = json["title"].stringValue
            self.buttonTitle = json["button_title"].stringValue
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
