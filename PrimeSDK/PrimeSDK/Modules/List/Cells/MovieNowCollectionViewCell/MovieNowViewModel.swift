import Foundation
import SwiftyJSON

class MovieNowViewModel: ViewModelProtocol, ListItemConfigConstructible, ListItemViewModelProtocol {
    var viewName: String = ""
    var id: String

    var attributes: [String: Any] {
        return [
            "id": id
        ]
    }

    let genres: [String]
    let title: String?
    let IMDBRating: String?
    let descriptionText: String?
    var isFavorite: Bool
    let imagePath: String?
    var sdkManager: PrimeSDKManagerProtocol?
    var favoriteAction: LoadConfigAction?
    var isIMax: Bool = false
    var premiereDate: Date?
    var canSalePushkinCard: Bool = false

    convenience init(
        viewName: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: MovieNowConfigView.Attributes?,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.init(
            name: viewName,
            valueForAttributeID: valueForAttributeID,
            defaultAttributes: nil,
            position: nil,
            getDistanceBlock: nil,
            sdkManager: sdkManager,
            configuration: configuration
        )
    }


    required init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: ListItemConfigView.Attributes?,
        position: Int?,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)?,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.viewName = name
        id = valueForAttributeID["id"] as? String ?? ""
        if let genresArray = valueForAttributeID["genres"] as? [[String: Any]] {
            genres = genresArray.compactMap { $0["name"] as? String }
        } else if let genresArray = valueForAttributeID["genres"] as? [String] {
            genres = genresArray
        } else if let genresString = valueForAttributeID["genres"] as? String, valueForAttributeID.count > 3 {
            genres = [genresString]
        } else {
            genres = []
        }
        title = valueForAttributeID["title"] as? String
        IMDBRating = valueForAttributeID["imdb_rating"] as? String
        descriptionText = valueForAttributeID["description_text"] as? String
        isFavorite = (valueForAttributeID["is_fave"] as? String) == "1"
        imagePath = valueForAttributeID["image_path"] as? String

        if let formatsArray = valueForAttributeID["formats"] as? [String] {
            isIMax = formatsArray.contains("imax")
        }

        self.sdkManager = sdkManager
        if
            let configView = configuration.views[viewName] as? MovieNowConfigView,
            let favoriteActionName = configView.actions.toggleFavorite,
            let action = configuration.actions[favoriteActionName] as? LoadConfigAction
        {
            self.favoriteAction = action
        }

        if let dateString = valueForAttributeID["premiere_date"] as? String {
            print("parsing date sring \(dateString)")
            if let date = Date(string: dateString) {
                if date > Date() {
                    self.premiereDate = date
                } else {
                    self.premiereDate = nil
                }
            }
        } else {
            self.premiereDate = nil
        }

        if let canSaleString = valueForAttributeID["can_sale_pushkin_card"] as? String {
            self.canSalePushkinCard = NSString(string: canSaleString).boolValue
        }
    }

    init() {
        self.viewName = ""
        self.title = ""
        self.id = ""
        self.descriptionText = ""
        self.isFavorite = false
        self.genres = []
        self.IMDBRating = ""
        self.imagePath = ""
    }

    func makeCell(
        for collectionView: UICollectionView,
        indexPath: IndexPath,
        listState: ListViewState
    ) -> UICollectionViewCell {
        let cell: MovieNowCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.isSkeletonShown = listState == .loading
        cell.update(with: self)
        return cell
    }
}
