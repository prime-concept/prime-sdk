import Foundation

class MovieFriendsLikesViewModel: DetailBlockViewModel, ViewModelProtocol, ListViewModelProtocol, Equatable {
    typealias ItemType = Friend

    var detailRow: DetailRow {
        return .movieFriendsLikes
    }

    var viewName: String

    var id: String
    var shareTitle: String
    var shareImagePath: String
    var backgroundColor: UIColor = .white

    var attributes: [String: Any] {
        [
            "id": id,
            "share_title": shareTitle,
            "share_image_path": shareImagePath
        ]
    }

    var viewCount: Int
    var isFavorite: Bool

    var visitedFriends: [Friend] = []
    var wantToVisitFriends: [Friend] = []

    var friends: [Friend] {
        return visitedFriends + wantToVisitFriends
    }

    var loadAction: LoadConfigAction?
    var favoriteAction: LoadConfigAction?
    var shareAction: ShareConfigAction?

    var sdkManager: PrimeSDKManagerProtocol

    init?(
        viewName: String,
        valueForAttributeID: [String: Any],
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        guard
            let viewCountString = valueForAttributeID["view_count"] as? String,
            let viewCount = Int(viewCountString),
            let configView = configuration.views[viewName] as? MovieFriendsLikesConfigView,
            let id = valueForAttributeID["id"] as? String
        else {
            self.viewName = viewName
            self.sdkManager = sdkManager
            self.viewCount = 0
            self.id = ""
            self.isFavorite = false
            self.shareImagePath = ""
            self.shareTitle = ""
            return
        }

        self.viewName = viewName
        self.id = id
        self.isFavorite = (valueForAttributeID["is_favorite"] as? String) == "1"
        self.shareImagePath = (valueForAttributeID["share_image_path"] as? String) ?? ""
        self.shareTitle = (valueForAttributeID["share_title"] as? String) ?? ""

        if
            let backgroundColorString = valueForAttributeID["background_color"] as? String,
            let backgroundColor = UIColor(hex: backgroundColorString)
        {
            self.backgroundColor = backgroundColor
        }

        self.viewCount = viewCount
        self.sdkManager = sdkManager

        if let loadActionName = configView.actions.load {
            self.loadAction = configuration.actions[loadActionName] as? LoadConfigAction
        }

        if let favoriteActionName = configView.actions.toggleFavorite {
            self.favoriteAction = configuration.actions[favoriteActionName] as? LoadConfigAction
        }

        if let shareActionName = configView.actions.share {
            self.shareAction = configuration.actions[shareActionName] as? ShareConfigAction
        }
    }

    func initFriends(
        valueForAttributeID: [String: Any]
    ) {
        self.visitedFriends = self.initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "visited_friends",
            initBlock: { valueForAttributeID, _ in
                Friend(valueForAttributeID: valueForAttributeID)
            }
        )
        self.wantToVisitFriends = self.initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "want_visit_friends",
            initBlock: { valueForAttributeID, _ in
                Friend(valueForAttributeID: valueForAttributeID)
            }
        )
    }

    class Friend {
        var imagePath: String

        init?(
            valueForAttributeID: [String: Any]
        ) {
            guard let imagePath = valueForAttributeID["image"] as? String else {
                return nil
            }
            self.imagePath = imagePath
        }
    }

    static func == (lhs: MovieFriendsLikesViewModel, rhs: MovieFriendsLikesViewModel) -> Bool {
        return lhs.id == rhs.id && lhs.viewName == rhs.viewName
    }
}
