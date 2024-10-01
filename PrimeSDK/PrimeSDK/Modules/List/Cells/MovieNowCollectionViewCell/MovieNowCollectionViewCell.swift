import UIKit

final class MovieNowCollectionViewCell: TileCollectionViewCell<
    MovieNowTileView, MovieNowViewModel
>, ViewReusable, FavoritableCellProtocol {
    override var leadingAnchorConstant: CGFloat { return -7.5 }
    override var trailingAnchorConstant: CGFloat { return 0 }
    override var bottomAnchorConstant: CGFloat { return 0 }
    override var topAnchorConstant: CGFloat { return 0 }

    var onAddToFavoriteButtonClick: (() -> Void)?

    override var isSkeletonShown: Bool {
        didSet {
            tileView.isSkeletonShown = isSkeletonShown
        }
    }

    func setFavorite(to: Bool) {
        tileView.isFavorite = to
    }

    override func update(with viewModel: MovieNowViewModel) {
        tileView.setup(viewModel: viewModel)
    }

    override func resetTile() {
        tileView.genres = []
        tileView.title = ""
        tileView.IMDBRating = nil
        tileView.descriptionText = ""
        tileView.isFavorite = false
        tileView.onFavoriteClick = nil
        tileView.imageView.image = nil
        tileView.canSalePushkinCard = false
    }
}

final class MovieNowTableViewCell: TileTableViewCell<
    MovieNowTileView, MovieNowViewModel
>, ViewReusable, FavoritableCellProtocol {
    var onAddToFavoriteButtonClick: (() -> Void)?

    override var leadingAnchorConstant: CGFloat { return 0 }
    override var trailingAnchorConstant: CGFloat { return 0 }
    override var bottomAnchorConstant: CGFloat { return -15 }
    override var topAnchorConstant: CGFloat { return 10 }

    var isSkeletonShown: Bool = false {
        didSet {
            tileView.isSkeletonShown = isSkeletonShown
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setFavorite(to: Bool) {
        tileView.isFavorite = to
    }

    override func update(with viewModel: MovieNowViewModel) {
        tileView.setup(viewModel: viewModel)
    }

    override func resetTile() {
        tileView.genres = []
        tileView.title = ""
        tileView.IMDBRating = nil
        tileView.descriptionText = ""
        tileView.isFavorite = false
        tileView.onFavoriteClick = nil
        tileView.imageView.image = nil
        tileView.canSalePushkinCard = false
    }
}
