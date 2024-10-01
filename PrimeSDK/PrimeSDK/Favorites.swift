import Foundation

public extension Notification.Name {
    static let itemFavoriteChanged = Notification.Name(
        rawValue: "itemFavoriteChanged"
    )

    static let detailItemFavoriteChanged = Notification.Name(
        rawValue: "detailItemFavoriteChanged"
    )
}

class Favorites {
    static let notificationItemIDKey = "id"
    static let notificationItemEntityTypeKey = "entity_type"
    static let notificationItemIsFavoriteNowKey = "isFavoriteNow"
}

struct FavoriteItem {
    var id: String
    var entityType: String
    var isFavoriteNow: Bool

    var userInfo: [AnyHashable: Any] {
        let userInfo: [String: Any] = [
            Favorites.notificationItemIDKey: id,
            Favorites.notificationItemEntityTypeKey: entityType,
            Favorites.notificationItemIsFavoriteNowKey: isFavoriteNow
        ]
        return userInfo
    }
}
