import Foundation
import SwiftyJSON

class DetailInfoConfigView: ConfigView {
    struct Attributes {
        var text: String
        var title: String
        var showTitle: Bool
        var showSkeleton: Bool

        init(json: JSON) {
            self.text = json["text"].stringValue
            self.title = json["title"].stringValue
            self.showTitle = json["show_title"].bool ?? false
            self.showSkeleton = json["show_skeleton"].bool ?? false
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
