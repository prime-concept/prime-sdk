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

class ListModuleParameters: ModuleParameters {
    struct Attributes {
        var id: String
    }
    var attributes: Attributes

    override init(json: JSON) {
        let id = json["attributes.id"].stringValue
        attributes = Attributes(id: id)
        super.init(json: json)
    }
}

class WebPageModuleParameters: ModuleParameters {
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

class DetailModuleParameters: ModuleParameters {
    struct Attributes {
        var id: String
    }
    var attributes: Attributes

    override init(json: JSON) {
        let id = json["attributes.id"].stringValue
        attributes = Attributes(id: id)
        super.init(json: json)
    }
}

class HomeModuleParameters: ModuleParameters {
    struct Attributes {
        var title: String
    }
    var attributes: Attributes

    override init(json: JSON) {
        let title = json["attributes.title"].stringValue
        attributes = Attributes(title: title)
        super.init(json: json)
    }
}
