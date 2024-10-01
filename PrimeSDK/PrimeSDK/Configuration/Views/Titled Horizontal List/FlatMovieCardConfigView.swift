import Foundation
import SwiftyJSON

class FlatMovieCardConfigView: ConfigView {
    struct Attributes {
        var title: String?
        var genres: [String]
        var imdbRating: Float?
        var imagePath: String?
        var id: String

        init(json: JSON) {
            self.id = json["id"].stringValue
            self.title = json["title"].string
            self.genres = (json["genres"].array ?? []).compactMap { $0["name"].string }
            self.imdbRating = json["imdb_rating"].float
            self.imagePath = json["image_path"].string
        }
    }
    var attributes: Attributes

    struct Actions {
        var tap: String

        init(json: JSON) {
            self.tap = json["tap"].stringValue
        }
    }
    var actions: Actions

    override init(json: JSON) {
        actions = Actions(json: json["actions"])
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}