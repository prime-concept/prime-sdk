import Foundation
import SwiftyJSON

class YoutubeVideoBlockConfigView: ConfigView {
    struct Attributes {
        var id: String
        var title: String?
        var author: String?

        var previewVideo: String?
        var previewImage: String?

        var shouldShowPlayButton: Bool

        init(json: JSON) {
            self.id = json["id"].stringValue
            self.title = json["title"].string
            self.author = json["author"].string

            self.previewVideo = json["preview_video"].string
            self.previewImage = json["preview_image"].string

            self.shouldShowPlayButton = json["should_show_play_button"].boolValue
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
