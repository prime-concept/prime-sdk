import Foundation
import SwiftyJSON

final class Quest {
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
    var coordinate: GeoCoordinate?

    required init(json: JSON) {
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

        if json["coordinates"].exists() {
            coordinate = GeoCoordinate(json: json["coordinates"])
        }
    }
}

final class ListHeaderViewModel {
    var id: String
    var title: String

    var description: String?
    var images: [GradientImage] = []

    var quests: [Quest] = []

    required init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        description = json["description"].string
        images = json["images"].arrayValue.compactMap(GradientImage.init)
    }

    init(valueForAttributeID: [String: Any]) throws {
        self.id = valueForAttributeID["header.id"] as? String ?? ""
        self.title = valueForAttributeID["header.title"] as? String ?? ""
        self.description = valueForAttributeID["header.description"] as? String ?? ""
        images = [
            try GradientImage(valueForAttributeID: valueForAttributeID)
        ]
    }
}
