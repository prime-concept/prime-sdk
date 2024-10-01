import Foundation
import SwiftyJSON

class AdBannerConfigView: ConfigView {
    struct Attributes {
        var blockID: String
        var parameters: [String: String]
        var height: Float

        init(json: JSON) {
            self.blockID = json["block_id"].stringValue
            self.parameters = json["parameters"].dictionaryValue.mapValues({ $0.stringValue })
            if let value = json["height"].float {
                self.height = value
            } else {
                if #available(iOS 11, *) {
                    self.height = Float.leastNonzeroMagnitude
                } else {
                    self.height = 1.1
                }
            }
        }
    }
    var attributes: Attributes


    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
