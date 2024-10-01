import Foundation
import SwiftyJSON

class DetailTagsConfigView: ConfigView {
    struct Attributes {
        var items: [String]
        var textColor: String?

        init(json: JSON) {
            self.items = json["items"].arrayValue.compactMap(String.init)
            self.textColor = json["text_color"].string
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
