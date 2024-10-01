import Foundation
import SkeletonView

final class HomeMoviePlainCardCollectionViewCell: TileCollectionViewCell<
    HomeMoviePlainCard, HomeMoviePlainCardViewModel
>, ViewReusable {
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 11, *) {
            tileView.cornerRadius = CGFloat.leastNonzeroMagnitude
        } else {
            tileView.cornerRadius = 1.1
        }
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }

    override var isSkeletonShown: Bool {
        didSet {
            self.tileView.isSkeletonShown = isSkeletonShown
        }
    }

    override func update(with viewModel: HomeMoviePlainCardViewModel) {
        tileView.setup(viewModel: viewModel)
    }

    override var needsShadow: Bool {
        return false
    }

    override func resetTile() {
//        tileView.transform = .identity
        tileView.reset()
    }
}
