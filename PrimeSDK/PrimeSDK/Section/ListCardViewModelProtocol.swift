import Foundation
import UIKit

struct ItemDetailsState: Equatable {
    let isRecommended: Bool
    var isFavoriteAvailable: Bool
    var isFavorite: Bool
}

protocol ListCardViewModelProtocol {
    var title: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
    var leftTopText: String? { get }
    var titleColor: UIColor { get }

    var position: Int? { get }
}
