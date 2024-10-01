import Foundation
import SwiftyJSON

class DetailContainerConfigView: ConfigView {
    struct Attributes {
        var id: String?
        var isFavoriteEnabled: Bool = false
        var entityType: String?
        var allowsLocation: Bool = false
        var isBottomButtonEnabled: Bool = false
        var buttonUrl: String?
        var buttonTitle: String?
        var shareUrl: String?
        var ticketPurchaseModule: String?
        var ticketPurchaseModuleSource: String?
        var ticketPurchaseModuleShowButton: Bool = false
        var backgroundColorRGB: String = "ffffff"

        init(json: JSON) {
            self.id = json["id"].string
            self.isFavoriteEnabled = json["is_favorite_enabled"].bool ?? self.isFavoriteEnabled
            self.entityType = json["entity_type"].string
            self.allowsLocation = json["allow_location"].bool ?? allowsLocation
            self.isBottomButtonEnabled = json["is_bottom_button_enabled"].bool ?? isBottomButtonEnabled
            self.buttonTitle = json["bottom_button_title"].string
            self.shareUrl = json["share_url"].string
            self.buttonUrl = json["bottom_button_url"].string
            self.ticketPurchaseModule = json["ticket_purchase_module"].string
            self.ticketPurchaseModuleSource = json["ticket_purchase_module_source"].string
            self.ticketPurchaseModuleShowButton = json["ticket_purchase_module_show_button"].boolValue
            self.backgroundColorRGB = json["background_color"].string ?? self.backgroundColorRGB
        }
    }
    var attributes: Attributes

    struct Actions {
        var load: String?
        var toggleFavorite: String?
        var openModule: String?
        var share: String?

        init(json: JSON) {
            self.load = json["load"].string
            self.toggleFavorite = json["toggle_favorite"].string
            self.openModule = json["open_module"].string
            self.share = json["share"].string
        }
    }
    var actions: Actions

    var header: String
    var subviews: [String]

    override init(json: JSON) {
        header = json["header"].stringValue
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])
        subviews = json["subviews"].arrayObject as? [String] ?? []

        super.init(json: json)
    }
}
