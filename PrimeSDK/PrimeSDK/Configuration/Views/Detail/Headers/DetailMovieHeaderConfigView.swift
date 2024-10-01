import Foundation
import SwiftyJSON

class DetailMovieHeaderConfigView: ConfigView {
    struct Attributes {
        var title: String?
        var backgroundColorRGB: String = "ffffff"

        init(json: JSON) {
            self.title = json["title"].string
            self.backgroundColorRGB = json["background_color"].string ?? self.backgroundColorRGB
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        super.init(json: json)
    }
}

