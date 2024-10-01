import Foundation
import SwiftyJSON

class HomeVerticalContainerConfigView: ConfigView {
    var subviews: [String]
    var header: String?
    var geoSubviews: [GeoSubview]

    struct GeoSubview {
        var cities: [Int]
        var subviews: [String]

        init?(json: JSON) {
            guard
                let cities = json["cities"].arrayObject as? [Int],
                let subviews = json["subviews"].arrayObject as? [String]
            else {
                return nil
            }
            self.cities = cities
            self.subviews = subviews
        }
    }

    struct Attributes {
        var inset: Float = 0
        var text: String = ""
        var textColor: UIColor = .white
        var alpha: Float = 0.45
        var isHidden: Bool = false
        var url: String = ""
        var radius: Float = 17.5

        init(json: JSON) {
            self.text = json["text"].string ?? ""
            self.url = json["url"].string ?? ""
            self.textColor = UIColor(hex: json["text_color"].stringValue) ?? self.textColor
            self.alpha = json["alpha"].float ?? self.alpha
            self.isHidden = json["hidden"].bool ?? self.isHidden
            self.inset = json["inset"].float ?? self.inset
            self.radius = json["radius"].float ?? self.radius
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        subviews = json["subviews"].arrayObject as? [String] ?? []
        geoSubviews = json["geo"].arrayValue.compactMap { GeoSubview(json: $0) }
        header = json["header"].string
        super.init(json: json)
    }
}

class HomeImageConfigView: ConfigView {
    struct Attributes {
        var path: String
        var height: Float = 500
        var gradientHeight: Float = 100

        init(json: JSON) {
            self.path = json["path"].stringValue
            self.height = json["height"].float ?? self.height
            self.gradientHeight = json["gradient_height"].float ?? self.gradientHeight
        }
    }
    var attributes: Attributes

    struct Actions {
        var load: String

        init(json: JSON) {
            self.load = json["load"].stringValue
        }
    }
    var actions: Actions

    override init(json: JSON) {
        actions = Actions(json: json["actions"])
        attributes = Attributes(json: json["attributes"])
        super.init(json: json)
    }
}
