import Foundation
import SwiftyJSON
import UIColor_Hex_Swift

protocol ListItemConfigConstructible {
    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: ListItemConfigView.Attributes?,
        position: Int?,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)?,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    )
}

struct ListItemViewModel: ListCardViewModelProtocol, Equatable, ListItemViewModelProtocol,
TitledHorizontalListCardViewModelProtocol {
    var title: String? = ""
    var subtitle: String?
    var titleColor = UIColor.black
    var imagePath: String?
    var leftTopText: String?
    var tapUrl: String?
    var id: String = ""
    var entityType: String = ""
    var routeDescription: String =  ""

    var isFavorite: Bool = false
    var isFavoriteAvailable: Bool = false
    var isSharingAvailable: Bool = false

    var startDate: Date?
    var endDate: Date?

    var viewName: String = ""

    var imageURL: URL? {
        return imagePath.flatMap(URL.init)
    }

    var width: CGFloat = 0
    var height: CGFloat = 0

    var position: Int?

    var sdkManager: PrimeSDKManagerProtocol?
    var shareAction: ShareConfigAction?
    var favoriteAction: LoadConfigAction?

    init(title: String, titleColor: UIColor) {
        self.title = title
        self.titleColor = titleColor
    }

    //TODO: Make failable init - could not parse view
    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: ListItemConfigView.Attributes? = nil,
        position: Int? = nil,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)? = nil,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.init(
            name: name,
            attributes: defaultAttributes,
            sdkManager: sdkManager,
            configuration: configuration
        )
        self.title = valueForAttributeID["title"] as? String ?? self.title
        self.subtitle = valueForAttributeID["subtitle"] as? String ?? self.subtitle
        self.tapUrl = valueForAttributeID["tap_url"] as? String ?? self.tapUrl
        self.imagePath = valueForAttributeID["image_path"] as? String ?? self.imagePath
        self.leftTopText = valueForAttributeID["badge"] as? String ?? self.leftTopText
        if let titleColorHex = valueForAttributeID["title_color"] as? String {
            self.titleColor = UIColor(titleColorHex)
        }
        self.id = valueForAttributeID["id"] as? String ?? self.id
        self.isFavorite = valueForAttributeID["is_favorite"] as? Bool ?? self.isFavorite
        self.isFavoriteAvailable = defaultAttributes?.isFavoriteEnabled ?? false
        self.isSharingAvailable = defaultAttributes?.isSharingEnabled ?? false

        self.entityType = valueForAttributeID["entity_type"] as? String ?? self.entityType
        if
            let lat = valueForAttributeID["lat"] as? Double,
            let lon = valueForAttributeID["lon"] as? Double,
            let distance = getDistanceBlock?(GeoCoordinate(lat: lat, lng: lon)) {
                self.leftTopText = FormatterHelper.format(distanceInMeters: distance)
        }

        if let dateString = valueForAttributeID["start_date"] as? String {
            self.startDate = Date(string: dateString)
        }

        if let dateString = valueForAttributeID["end_date"] as? String {
            self.endDate = Date(string: dateString)
        }

        self.position = position

        self.subtitle = getSubtitle() ?? self.subtitle

        self.routeDescription = valueForAttributeID["route_description"] as? String ?? routeDescription

        self.sdkManager = sdkManager

        if let configView = configuration.views[viewName] as? ListItemConfigView {
            if let shareActionName = configView.actions.share,
                let action = configuration.actions[shareActionName] as? ShareConfigAction {
                self.shareAction = action
            }
            if let favoriteActionName = configView.actions.toggleFavorite,
                let action = configuration.actions[favoriteActionName] as? LoadConfigAction {
                self.favoriteAction = action
            }
        }
    }

    init(
        name: String,
        attributes: ListItemConfigView.Attributes?,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        guard let attributes = attributes else {
            return
        }
        self.viewName = name
        if let color = attributes.titleColor {
            self.titleColor = UIColor(color)
        }
        self.title = attributes.title
        self.tapUrl = attributes.tapUrl
        self.subtitle = attributes.subtitle
        self.imagePath = attributes.imagePath
        self.id = attributes.id ?? self.id
        self.isFavoriteAvailable = attributes.isFavoriteEnabled
        self.isSharingAvailable = attributes.isSharingEnabled
        self.entityType = attributes.entityType ?? self.entityType
        self.startDate = attributes.startDate
        self.endDate = attributes.endDate
        self.sdkManager = sdkManager
    }

    var attributes: [String: Any] {
        return [
            "title": title as Any,
            "title_color": titleColor.hexString(),
            "tap_url": tapUrl as Any,
            "id": id as Any,
            "width": Int(width),
            "height": Int(height),
            "entity_type": entityType as Any,
            "image_path": imagePath ?? ""
        ]
    }

    private func getSubtitle() -> String? {
        let formattedDate = FormatterHelper.formatDateInterval(
            from: startDate,
            to: endDate
        ) ?? ""

        guard !formattedDate.isEmpty else {
            return subtitle
        }

        guard !(subtitle ?? "").isEmpty else {
            return "\(formattedDate)"
        }

        return "\(subtitle ?? "") · \(formattedDate)"
    }

    //TODO: remove after detail refactoring
    static func == (lhs: ListItemViewModel, rhs: ListItemViewModel) -> Bool {
        return lhs.title == rhs.title
            && lhs.subtitle == rhs.subtitle
            && lhs.titleColor == rhs.titleColor
            && lhs.imagePath == rhs.imagePath
            && lhs.leftTopText == rhs.leftTopText
            && lhs.tapUrl == rhs.tapUrl
            && lhs.id == rhs.id
            && lhs.entityType == rhs.entityType
            && lhs.routeDescription == rhs.routeDescription
            && lhs.isFavorite == rhs.isFavorite
            && lhs.position == rhs.position
    }

    func makeCell(
        for collectionView: UICollectionView,
        indexPath: IndexPath,
        listState: ListViewState
    ) -> UICollectionViewCell {
        let cell: ListCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.isSkeletonShown = listState == .loading
        cell.update(with: self)
        return cell
    }
}
