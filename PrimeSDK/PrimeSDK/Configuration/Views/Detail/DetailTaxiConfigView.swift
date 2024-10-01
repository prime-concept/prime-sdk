import Foundation
import SwiftyJSON

class DetailTaxiConfigView: ConfigView {
    struct Attributes {
        var yandexPrice: Int?
        var yandexURL: String?

        init(json: JSON) {
            self.yandexURL = json["yandex_url"].string
            self.yandexPrice = json["yandex_price"].int
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
