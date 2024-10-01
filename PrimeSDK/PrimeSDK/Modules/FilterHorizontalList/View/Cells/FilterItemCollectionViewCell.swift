import SkeletonView
import UIKit

final class FilterItemCollectionViewCell: TileCollectionViewCell<
    FilterItemTileView, FilterItemViewModel
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

    override func update(with viewModel: FilterItemViewModel) {
        tileView.setup(viewModel: viewModel)
    }

    override var needsShadow: Bool {
        return false
    }

    override func resetTile() {
        tileView.transform = .identity
        tileView.reset()
    }
}
