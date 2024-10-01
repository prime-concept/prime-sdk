import Foundation

class HomeSelectionCardViewModel: TitledHorizontalListCardViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "id": id,
            "title": title ?? ""
        ]
    }

    var id: String = ""
    var title: String?
    var subtitle: String
    var imagePath: String

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: HomeSelectionCardConfigView.Attributes? = nil
    ) {
        self.viewName = name

        self.id = valueForAttributeID["id"] as? String ?? defaultAttributes?.id ?? ""
        self.title = valueForAttributeID["title"] as? String ?? defaultAttributes?.title ?? ""
        self.subtitle = valueForAttributeID["subtitle"] as? String ?? defaultAttributes?.subtitle ?? ""
        self.imagePath = valueForAttributeID["image_path"] as? String ?? defaultAttributes?.imagePath ?? ""
    }

    init(
        title: String
    ) {
        self.viewName = ""
        self.title = title
        self.imagePath = ""
        self.subtitle = ""
    }

    var imageURL: URL? {
        return URL(string: imagePath)
    }

    static var dummyViewModel = HomeSelectionCardViewModel(
        title: "Loading"
    )
}
