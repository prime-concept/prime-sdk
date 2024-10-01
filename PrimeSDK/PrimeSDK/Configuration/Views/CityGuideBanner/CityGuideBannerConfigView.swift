import Foundation
import SwiftyJSON

class CityGuideBannerConfigView: ConfigView {
    struct CityConfig {
        var imageURL: String
        var contentURL: String
        var headers: [String: String]

        var isEmpty: Bool {
            return self.imageURL.isEmpty || self.contentURL.isEmpty
        }

        init(json: JSON) {
            self.imageURL = json["image_url"].stringValue
            self.contentURL = json["content_url"].stringValue
            self.headers = (json["headers"].dictionaryObject as? [String: String]) ?? [:]
        }
    }

    struct Attributes {
        var height: Float
        var citiesConfig: [String: CityConfig] = [:]
        var defaultConfig: CityConfig


        init(json: JSON) {
            self.height = json["height"].float ?? 300

            self.defaultConfig = CityConfig(json: json["default_config"])
            json["cities_config"].dictionaryValue.forEach { (id, json) in
                self.citiesConfig[id] = CityConfig(json: json)
            }
        }
    }

    var attributes: Attributes

    override init(json: JSON) {
        self.attributes = Attributes(json: json["attributes"])
        super.init(json: json)
    }
}
