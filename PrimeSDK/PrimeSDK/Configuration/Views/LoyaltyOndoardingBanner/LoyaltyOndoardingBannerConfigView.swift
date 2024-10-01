import Foundation
import SwiftyJSON

class LoyaltyOnboardingBannerConfigView: ConfigView {
    struct Attributes {
        let height: Float
        let imageURL: String
        let contentURL: String

        init(json: JSON) {
            self.height = json["height"].float ?? 130
            self.imageURL = json["image_url"].stringValue
            self.contentURL = json["content_url"].stringValue
        }
    }

    let attributes: Attributes

    override init(json: JSON) {
        self.attributes = Attributes(json: json["attributes"])
        super.init(json: json)
    }
}
