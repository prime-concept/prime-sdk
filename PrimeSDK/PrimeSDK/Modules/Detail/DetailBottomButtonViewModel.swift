import Foundation
import UIColor_Hex_Swift

struct DetailBottomButtonViewModel: ViewModelProtocol {
    var viewName: String = "detail-booking-button"

    var attributes: [String: Any] {
        return [
            "tap_url": urlPath as Any
        ]
    }

    var urlPath: String
    var title: String?
    var background: UIColor?
    var text: UIColor?

    var url: URL? {
        return URL(string: urlPath)
    }

    init?(
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailContainerConfigView.Attributes? = nil
    ) {
        guard
            let urlPath = (valueForAttributeID["bottom_button_url"] as? String ?? defaultAttributes?.buttonUrl),
            let title = (valueForAttributeID["bottom_button_title"] as? String ?? defaultAttributes?.buttonTitle)
        else {
            return nil
        }

        if let backgroundString = valueForAttributeID["bottom_button_background"] as? String {
            self.background = UIColor(hex: backgroundString)
        }
        if let textString = valueForAttributeID["bottom_button_text"] as? String {
            self.text = UIColor(hex: textString)
        }

        self.title = title
        self.urlPath = urlPath
    }
}
