import Foundation
import SwiftyJSON

class HorizontalListsContainerConfigView: ConfigView {
    var subviews: [String]

//    struct Attributes {
//        var supportPagination: Bool
//        var hasHeader: Bool
//        var allowsLocation: Bool
//        var itemHeight: Float?
//
//        init(json: JSON) {
//            self.supportPagination = json["support_pagination"].boolValue
//            self.hasHeader = json["has_header"].boolValue
//            self.allowsLocation = json["allow_location"].boolValue
//            self.itemHeight = json["item_height"].float
//        }
//    }
//    var attributes: Attributes
//    
//    struct Actions {
//        var load: String
//        init(json: JSON) {
//            self.load = json["load"].stringValue
//        }
//    }
//    var actions: Actions

    override init(json: JSON) {
        subviews = json["subviews"].arrayObject as? [String] ?? []
//        attributes = Attributes(json: json["attributes"])
//        actions = Actions(json: json["actions"])
        super.init(json: json)
    }
}
