import Foundation
import SwiftyJSON

class SharingParameters {
    var type: String

    init(json: JSON) {
        self.type = json["type"].stringValue
    }
}

class BranchSharingParameters: SharingParameters {
    struct Attributes {
        var title: String
        var imagePath: String
    }

    var attributes: Attributes

    override init(json: JSON) {
        let title = json["title"].stringValue
        let imagePath = json["image_path"].stringValue
        attributes = Attributes(title: title, imagePath: imagePath)
        super.init(json: json)
    }
}

class UrlSharingParameters: SharingParameters {
    struct Attributes {
        var url: String
    }

    var attributes: Attributes

    override init(json: JSON) {
        let url = json["url"].stringValue
        attributes = Attributes(url: url)
        super.init(json: json)
    }
}

class ShareConfigAction: ConfigAction {
    let sharingParametersFactory = SharingParametersFactory()
    let moduleParametersFactory = ModuleParametersFactory()

    var moduleParameters: ModuleParameters
    var sharingParameters: SharingParameters

    override init(json: JSON) throws {
        let moduleParametersJson = json["module_parameters"]
        guard
            moduleParametersJson.dictionary != nil
        else {
            throw ModuleParametersMissingError()
        }

        let sharingParametersJson = json["sharing_parameters"]
        guard
            sharingParametersJson.dictionary != nil
        else {
            throw ModuleParametersMissingError()
        }

        moduleParameters = try moduleParametersFactory.make(from: moduleParametersJson)
        sharingParameters = try sharingParametersFactory.make(from: sharingParametersJson)

        try super.init(json: json)
    }
}
