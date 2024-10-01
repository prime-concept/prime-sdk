import Foundation
import SwiftyJSON

final class MovieNowConfigView: ConfigView {
    struct Attributes {
        var id: String?
        var title: String?
        var genres: [String]
        var IMDBRating: String?
        var descriptionText: String?
        var isFavorite: Bool
        var imagePath: String?

        init(json: JSON) {
            id = json["id"].string
            title = json["title"].string
            genres = (json["genres"].array ?? []).compactMap { $0["name"].string }
            IMDBRating = json["imdb_rating"].string
            descriptionText = json["description"].string
            isFavorite = json["is_fave"].bool ?? false
            imagePath = json["image_path"].string
        }
    }

    struct Actions {
        var tap: String?
        var toggleFavorite: String?

        init(json: JSON) {
            tap = json["tap"].string
            toggleFavorite = json["toggle_favorite"].string
        }
    }

    var attributes: Attributes
    var actions: Actions

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])
        super.init(json: json)
    }
}
