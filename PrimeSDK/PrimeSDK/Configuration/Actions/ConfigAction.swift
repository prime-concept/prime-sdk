import Foundation
import SwiftyJSON

class ConfigAction {
    var type: String
    var name: String

    init(json: JSON) throws {
        self.type = json["type"].stringValue
        self.name = json["name"].stringValue
    }
}
