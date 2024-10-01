import Foundation
import SwiftyJSON

class DetailCinemaHeaderConfigView: ConfigView {
    struct Attributes {
        var title: String?

        init(json: JSON) {
            self.title = json["title"].string
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        super.init(json: json)
    }
}
