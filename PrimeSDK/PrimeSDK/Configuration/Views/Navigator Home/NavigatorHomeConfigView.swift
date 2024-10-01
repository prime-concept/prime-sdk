import Foundation
import SwiftyJSON

class NavigatorHomeConfigView: ConfigView {
//    struct Attributes {
//        var supportPagination: Bool
//
//        init(json: JSON) {
//            self.supportPagination = json["support_pagination"].boolValue
//        }
//    }
//    var attributes: Attributes

    var subviews: [String]

    struct Actions {
        var load: String
        init(json: JSON) {
            self.load = json["load"].stringValue
        }
    }
    var actions: Actions

    override init(json: JSON) {
//        attributes = Attributes(json: json["attributes"])
        subviews = json["subviews"].arrayObject as? [String] ?? []
        actions = Actions(json: json["actions"])
        super.init(json: json)
    }
}
