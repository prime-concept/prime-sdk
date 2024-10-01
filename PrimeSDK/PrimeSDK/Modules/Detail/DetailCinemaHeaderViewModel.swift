import Foundation

struct DetailCinemaHeaderViewModel: ViewModelProtocol, DetailHeaderViewModelProtocol, Equatable {
    func isEqualTo(otherHeader: DetailHeaderViewModelProtocol) -> Bool {
        guard let otherHeader = otherHeader as? DetailCinemaHeaderViewModel else {
            return false
        }
        return self == otherHeader
    }

    var viewName: String = ""

    var title: String?
    var shortTitle: String?
    var imagePath: String?

    var badges: [CinemaBadge] = []
    var hasBadge: Bool {
        return !badges.isEmpty
    }

    init(
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailCinemaHeaderConfigView.Attributes? = nil
    ) {
        self.init(attributes: defaultAttributes)
        self.title = valueForAttributeID["title"] as? String ?? self.title
        self.shortTitle = valueForAttributeID["short_title"] as? String
        self.imagePath = valueForAttributeID["image"] as? String

        if let labelsArray = valueForAttributeID["badges"] as? [[String: Any]] {
            badges = labelsArray.compactMap({ CinemaBadge(dict: $0) })
            badges = badges.sorted(
                by: { first, _ in
                    switch first {
                    case .text:
                        return true
                    case .icon:
                        return false
                    }
                }
            )
        } else {
            badges = []
        }
    }

    init() {}

    init(attributes: DetailCinemaHeaderConfigView.Attributes?) {
        guard let attributes = attributes else {
            return
        }
        self.title = attributes.title
    }

    var attributes: [String: Any] {
        return [
            "title": title as Any
        ]
    }
}

