import UIKit

protocol ShadowHeightReportingCellProtocol {
    static var shadowHeight: CGFloat { get }
}

final class CinemaCardCollectionViewCell: TileCollectionViewCell<
    CinemaTileView, CinemaCardViewModel
>, ViewReusable, FavoritableCellProtocol, ShadowHeightReportingCellProtocol {
    static let topShadowHeight: CGFloat = 2
    static let bottomShadowHeight: CGFloat = 5
    static let shadowHeight = topShadowHeight + bottomShadowHeight

    override var topAnchorConstant: CGFloat {
        return CinemaCardCollectionViewCell.topShadowHeight
    }
    override var bottomAnchorConstant: CGFloat {
        return -CinemaCardCollectionViewCell.bottomShadowHeight
    }

    var onAddToFavoriteButtonClick: (() -> Void)? {
        didSet {
            tileView.onFavoriteClick = onAddToFavoriteButtonClick
        }
    }

    func setFavorite(to: Bool) {
        tileView.isFavorite = to
    }

    override func update(with viewModel: CinemaCardViewModel) {
        tileView.setup(viewModel: viewModel)
        tileView.shadowRadius = 4
        tileView.color = UIColor.black.withAlphaComponent(0.12)
        tileView.shadowOffset = CGSize(width: 0, height: 3)
        tileView.backgroundColor = .white
        tileView.onFavoriteClick = onAddToFavoriteButtonClick
    }

    override func resetTile() {
        tileView.reset()
    }

    override var isSkeletonShown: Bool {
        didSet {
            self.tileView.isSkeletonShown = isSkeletonShown
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
