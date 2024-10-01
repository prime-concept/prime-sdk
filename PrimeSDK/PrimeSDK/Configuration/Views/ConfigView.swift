import Foundation
import SwiftyJSON

class ConfigView {
    var type: String
    var name: String

    init(json: JSON) {
        self.type = json["type"].stringValue
        self.name = json["name"].stringValue
    }
}
