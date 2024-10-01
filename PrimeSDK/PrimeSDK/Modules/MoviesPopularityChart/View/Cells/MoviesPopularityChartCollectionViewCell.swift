import Foundation
import SkeletonView

final class MoviesPopularityChartCollectionViewCell: TileCollectionViewCell<
    MoviesPopularityChartView, MoviesPopularityChartItemViewModel
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

    override func update(with viewModel: MoviesPopularityChartItemViewModel) {
        tileView.setup(viewModel: viewModel, config: .default)
    }

    override var needsShadow: Bool {
        return false
    }

    override func resetTile() {
        tileView.reset()
    }
}
