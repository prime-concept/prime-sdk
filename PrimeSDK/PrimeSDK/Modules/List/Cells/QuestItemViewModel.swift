import Foundation

struct QuestHeaderViewModel {
    var info: String?
    var questViewModels: [QuestItemViewModel] = []

    init(questHeader: ListHeaderViewModel, questViewModels: [QuestItemViewModel]) {
        info = questHeader.description
        self.questViewModels = questViewModels
    }

    init(
        name: String,
        valueForAttributeID: [String: Any]
    ) {
    }
}

struct QuestItemViewModel: ViewModelProtocol, ListItemConfigConstructible {
    var viewName: String = ""
    var attributes: [String: Any] = [:]

    var title: String?
    var distance: Double?
    var place: String?
    var reward: Int
    var imagePath: String?
    var questState: QuestStatus?
    var color: UIColor?

    var position: Int?

    init(quest: Quest, distance: Double? = nil, position: Int? = nil) {
        title = quest.title
        self.distance = distance
        place = ""
        reward = quest.reward
        imagePath = quest.images.first?.image
        color = quest.images.first?.gradientColor
        self.position = position

        questState = quest.status
    }

    init(valueForAttributeID: [String: Any]) {
        self.title = valueForAttributeID["title"] as? String ?? ""
        self.distance = 0
        self.place = valueForAttributeID["place"] as? String ?? ""
        self.imagePath = valueForAttributeID["image"] as? String ?? ""
        self.questState = QuestStatus(status: valueForAttributeID["state"] as? String ?? "")
        self.reward = 1
    }


    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: ListItemConfigView.Attributes?,
        position: Int? = nil,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)? = nil,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.init(valueForAttributeID: valueForAttributeID)
    }
}

extension QuestItemViewModel {
    var subtitle: String? {
        return place
    }

    var imageURL: URL? {
        guard let imagePath = imagePath else {
            return nil
        }

        return URL(string: imagePath)
    }

    var leftTopText: String {
        guard let distance = distance else {
            return ""
        }

        return FormatterHelper.format(distanceInMeters: distance)
    }

    var state: ItemDetailsState {
        return ItemDetailsState(
            isRecommended: false,
            isFavoriteAvailable: false,
            isFavorite: false
        )
    }
}
