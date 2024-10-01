import Foundation

struct Subway: Equatable {
    var name: String
    var color: UIColor

    init?(valueForAttributeID: [String: Any]) {
        guard
            let name = valueForAttributeID["name"] as? String,
            let colorString = valueForAttributeID["color"] as? String,
            let color = UIColor(hex: colorString)
        else {
            return nil
        }
        self.name = name
        self.color = color
    }
}

protocol HeightReportingListItemViewModelProtocol: AnyObject {
    var height: CGFloat { get }
}

enum CinemaBadge: Equatable {
    case icon
    case text(text: String)

    init?(dict: [String: Any]) {
        guard let type = dict["type"] as? String else {
            return nil
        }

        switch type {
        case "icon":
            if dict["slug"] as? String == "combo" {
                self = .icon
            } else {
                return nil
            }
        case "text":
            if let text = dict["text"] as? String {
                self = .text(text: text)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

class CinemaCardViewModel: ViewModelProtocol, ListItemConfigConstructible,
HeightReportingListItemViewModelProtocol, ListItemViewModelProtocol {
    var viewName: String = ""
    var sourceName: String

    var id: String
    var title: String
    var mall: String
    var address: String
    var distance: Int?
    var isFavorite: Bool
    var favoriteAction: LoadConfigAction?
    var sdkManager: PrimeSDKManagerProtocol?
    var badges: [CinemaBadge] = []

    var distanceString: String? {
        if
            let distance = distance,
            distance != 0
        {
            return FormatterHelper.format(distanceInMeters: Double(distance))
        } else {
            return nil
        }
    }
    var subway: Subway?

    var hasBadge: Bool {
        return !badges.isEmpty
    }

    var attributes: [String: Any] {
        return [
            "id": id
        ]
    }

    init(
        title: String,
        mall: String,
        address: String
    ) {
        self.viewName = ""
        self.title = title
        self.address = address
        self.mall = mall
        self.id = ""
        self.isFavorite = false
        self.sourceName = ""
    }

    static var dummyViewModel = CinemaCardViewModel(
        title: "Loading",
        mall: "Mall",
        address: "Address"
    )

    init(
        viewName: String,
        sourceName: String?,
        valueForAttributeID: [String: Any],
        defaultAttributes: CinemaCardConfigView.Attributes? = nil,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.viewName = viewName
        self.sourceName = sourceName ?? valueForAttributeID["listName"] as? String ?? ""
        self.id = valueForAttributeID["id"] as? String ?? ""
        self.title = valueForAttributeID["title"] as? String ?? ""
        self.mall = valueForAttributeID["mall"] as? String ?? ""
        self.address = valueForAttributeID["address"] as? String ?? ""

        /// is_favorite comes from different endpoints as Int/String
        switch valueForAttributeID["is_favorite"] {
        case let isFavorite as String:
            self.isFavorite = isFavorite == "1"
        case let isFavorite as Int:
            self.isFavorite = isFavorite == 1
        default:
            self.isFavorite = false
        }

        if let distanceString = valueForAttributeID["distance"] as? String {
            self.distance = Int(distanceString)
        }
        self.sdkManager = sdkManager

        self.subway = Subway(
            valueForAttributeID: CinemaCardViewModel.getValuesForSubview(
                valueForAttributeID: valueForAttributeID,
                subviewName: "subway"
            )
        )

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

        if
            let configView = configuration.views[viewName] as? CinemaCardConfigView,
            let favoriteActionName = configView.actions.toggleFavorite,
            let action = configuration.actions[favoriteActionName] as? LoadConfigAction
        {
            self.favoriteAction = action
        }
    }

    required convenience init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: ListItemConfigView.Attributes?,
        position: Int?,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)?,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.init(
            viewName: name,
            sourceName: nil,
            valueForAttributeID: valueForAttributeID,
            sdkManager: sdkManager,
            configuration: configuration
        )
    }

    var height: CGFloat {
        // this changes came from CinemaCardCollectionViewCell
        let cardHeight: CGFloat = 77
        let badgeCardHeight: CGFloat = 97
        return hasBadge ? badgeCardHeight : cardHeight
    }

    func makeCell(
        for collectionView: UICollectionView,
        indexPath: IndexPath,
        listState: ListViewState
    ) -> UICollectionViewCell {
        let cell: CinemaCardCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.isSkeletonShown = listState == .loading
        cell.update(with: self)
        return cell
    }
}
