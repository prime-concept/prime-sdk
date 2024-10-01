import Foundation

struct FilterItemViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "id": id
        ]
    }

    var id: String = ""
    var title: String
    var action: String

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: FilterItemConfigView.Attributes? = nil
    ) {
        self.viewName = name
        self.title = valueForAttributeID["title"] as? String ?? defaultAttributes?.title ?? ""
        self.id = valueForAttributeID["id"] as? String ?? defaultAttributes?.title ?? ""
        self.action = valueForAttributeID["action"] as? String ?? defaultAttributes?.id ?? ""
    }

    init(
        id: String,
        title: String
    ) {
        self.viewName = ""
        self.id = id
        self.title = title
        self.action = ""
     }
}
