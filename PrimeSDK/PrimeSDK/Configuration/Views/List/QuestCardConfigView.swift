import Foundation
import SwiftyJSON

class QuestCardConfigView: ConfigView {
    struct Attributes {
        var id: String
        var title: String
        var question: String
        var answers: [String] = []
        var reward: Int
        var images: [GradientImage] = []
        var trueAnswer: Int
        var status: QuestStatus?

        var place: [String] = []
        var radius: Int?

        init(json: JSON) {
            id = json["id"].stringValue
            title = json["title"].stringValue
            question = json["question"].stringValue
            answers = json["answers"].arrayValue.map { $0.stringValue }
            reward = json["reward"].intValue
            images = json["images"].arrayValue.compactMap(GradientImage.init)
            trueAnswer = json["trueAnswer"].intValue
            status = QuestStatus(status: json["status"].stringValue)
            place = json["place"].arrayValue.map { $0.stringValue }
            radius = json["radius"].intValue
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
        attributes = Attributes(json: json["attributes"])
        actions = Actions(json: json["actions"])
        super.init(json: json)
    }
}
