import Foundation
import SwiftyJSON

class ListItemConfigView: ConfigView {
    struct Attributes {
        var titleColor: String?
        var title: String?
        var tapUrl: String?
        var subtitle: String?
        var imagePath: String?
        var leftTopText: String?
        var id: String?
        var isFavoriteEnabled: Bool
        var isSharingEnabled: Bool
        var entityType: String?
        var startDate: Date?
        var endDate: Date?

        init(json: JSON) {
            self.titleColor = json["title_color"].string
            self.title = json["title"].string
            self.tapUrl = json["tap_url"].string
            self.subtitle = json["subtitle"].string
            self.imagePath = json["image_path"].string
            self.leftTopText = json["badge"].string
            self.id = json["id"].string
            self.isFavoriteEnabled = json["is_favorite_enabled"].bool ?? false
            self.isSharingEnabled = json["is_sharing_enabled"].bool ?? false
            self.entityType = json["entity_type"].string

            if let dateString = json["start_date"].string {
                self.startDate = Date(string: dateString)
            }

            if let dateString = json["end_date"].string {
                self.endDate = Date(string: dateString)
            }
        }
    }
    var attributes: Attributes

    struct Actions {
        var tap: String?
        var toggleFavorite: String?
        var share: String?

        init(json: JSON) {
            self.tap = json["tap"].string
            self.toggleFavorite = json["toggle_favorite"].string
            self.share = json["share"].string
        }
    }
    var actions: Actions

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])
        super.init(json: json)
    }

    //TODO: Move to protocol & use with all cells
    var cellClassName = "SectionTableViewCell"
}
