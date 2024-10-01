import Foundation
import SwiftyJSON

class ModuleParameters {
    var type: String
    var name: String

    init(json: JSON) {
        self.type = json["type"].stringValue
        self.name = json["name"].stringValue
    }
}

final class ListModuleParameters: ModuleParameters {
    override init(json: JSON) {
        super.init(json: json)
    }
}

final class WebPageModuleParameters: ModuleParameters {
    struct Attributes {
        var url: String
    }
    var attributes: Attributes

    override init(json: JSON) {
        let url = json["attributes.url"].stringValue
        attributes = Attributes(url: url)
        super.init(json: json)
    }
}
