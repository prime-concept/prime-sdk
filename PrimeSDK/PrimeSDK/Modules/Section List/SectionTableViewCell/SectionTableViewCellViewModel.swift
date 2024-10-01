import Foundation
import SwiftyJSON
import UIColor_Hex_Swift

struct SectionTableViewCellViewModel: ViewModelProtocol, Equatable {
    var title: String?
    var subtitle: String?
    var titleColor = UIColor.black
    var imagePath: String?
    var leftTopText: String?
    var tapUrl: String?
    var id: String?

    var viewName: String = ""

    var imageURL: URL? {
        return imagePath.flatMap(URL.init)
    }

    var width: CGFloat = 0
    var height: CGFloat = 0

    var position: Int?

    init(title: String, titleColor: UIColor) {
        self.title = title
        self.titleColor = titleColor
    }

    //TODO: Make failable init - could not parse view
    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: SectionCardConfigView.Attributes? = nil,
        position: Int? = nil,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)? = nil
    ) {
        self.init(name: name, attributes: defaultAttributes)
        self.title = valueForAttributeID["title"] as? String ?? self.title
        self.subtitle = valueForAttributeID["subtitle"] as? String ?? self.subtitle
        self.tapUrl = valueForAttributeID["tap_url"] as? String ?? self.tapUrl
        self.imagePath = valueForAttributeID["image_path"] as? String ?? self.imagePath
        self.leftTopText = valueForAttributeID["left_top_text"] as? String ?? self.leftTopText
        if let titleColorHex = valueForAttributeID["title_color"] as? String {
            self.titleColor = UIColor(titleColorHex)
        }
        self.id = valueForAttributeID["id"] as? String ?? self.id
        if
            let lat = valueForAttributeID["lat"] as? Double,
            let lon = valueForAttributeID["lon"] as? Double,
            let distance = getDistanceBlock?(GeoCoordinate(lat: lat, lng: lon)) {
                self.leftTopText = FormatterHelper.format(distanceInMeters: distance)
        }

        self.position = position
    }

    init(name: String, attributes: SectionCardConfigView.Attributes?) {
        guard let attributes = attributes else {
            return
        }
        self.viewName = name
        if let color = attributes.titleColor {
            self.titleColor = UIColor(color)
        }
        self.title = attributes.title
        self.tapUrl = attributes.tapUrl
        self.subtitle = attributes.subtitle
        self.imagePath = attributes.imagePath
        self.id = attributes.id
    }

    var attributes: [String: Any] {
        return [
            "title": title as Any,
            "title_color": titleColor.hexString(),
            "tap_url": tapUrl as Any,
            "id": id as Any,
            "width": Int(width),
            "height": Int(height)
        ]
    }
}

extension SectionTableViewCellViewModel: SectionItemViewModelProtocol {
}
