import Foundation
import SwiftyJSON

class HomeColoredContainerConfigView: ConfigView {
    var subviews: [String]

    struct Attributes {
        var title: String = ""
        var titleColor: UIColor = .white
        var backgroundColorTop: UIColor = .black
        var backgroundColorBottom: UIColor = .black
        var radius: Float = 10

        init(json: JSON) {
            self.title = json["title"].string ?? ""
            self.titleColor = UIColor(hex: json["title_color"].stringValue) ?? self.titleColor
            self.backgroundColorTop = UIColor(hex: json["background_color_top"].stringValue) ?? self.backgroundColorTop
            self.backgroundColorBottom = UIColor(
                hex: json["background_color_bottom"].stringValue
            ) ?? self.backgroundColorBottom

            self.radius = json["radius"].float ?? self.radius
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        subviews = json["subviews"].arrayObject as? [String] ?? []
        super.init(json: json)
    }
}
