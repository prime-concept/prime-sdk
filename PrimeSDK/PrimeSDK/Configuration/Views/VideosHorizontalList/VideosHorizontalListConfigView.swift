import Foundation
import SwiftyJSON

class VideosHorizontalListConfigView: ConfigView {
    var videoBlock: String

    struct Attributes {
        var height: Float
        var title: String?
        var topInset: Float?
        var showQuiz: Bool

        init(json: JSON) {
            height = json["height"].float ?? 300
            title = json["title"].string
            topInset = json["top_inset"].float
            showQuiz = json["show_quiz"].bool ?? false
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
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])
        videoBlock = json["video_block"].stringValue
        super.init(json: json)
    }
}
