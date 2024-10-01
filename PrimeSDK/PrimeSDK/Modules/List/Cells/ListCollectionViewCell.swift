import UIKit

protocol FavoritableCellProtocol {
    func setFavorite(to: Bool)
}

//TODO: stay only for quests
protocol ShareableCellProtocol {
    var onShareButtonClick: (() -> Void)? { get set }
}

final class ListCollectionViewCell: TileCollectionViewCell<
    ActionTileView, ListItemViewModel
>, ViewReusable {
    override var leadingAnchorConstant: CGFloat { return 0 }
    override var trailingAnchorConstant: CGFloat { return 0 }
    override var bottomAnchorConstant: CGFloat { return -7.5 }
    override var topAnchorConstant: CGFloat { return 0 }

    override func update(with viewModel: ListItemViewModel) {
        tileView.title = viewModel.title
        tileView.subtitle = viewModel.subtitle
        tileView.leftTopText = viewModel.leftTopText

        tileView.isFavoriteButtonHidden = !viewModel.isFavoriteAvailable
        tileView.isFavoriteButtonSelected = viewModel.isFavorite
        tileView.isShareButtonHidden = !viewModel.isSharingAvailable

        tileView.color = .clear

        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }

        tileView.viewModel = viewModel
    }

    override func resetTile() {
        tileView.title = ""
        tileView.subtitle = ""
        tileView.leftTopText = ""
        tileView.shouldShowRecommendedBadge = false
        tileView.transform = .identity
    }
}
