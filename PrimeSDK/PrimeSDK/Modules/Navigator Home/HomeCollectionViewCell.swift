import UIKit

protocol HomeCellViewModelProtocol {
    var color: UIColor? { get }
    var title: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
}

final class HomeCollectionViewCell<ViewModel: HomeCellViewModelProtocol>:
TileCollectionViewCell<CenterTextTileView, ViewModel>, ViewReusable {
    private let defaultTileColor = UIColor.black
    private let backgroundTintColor = UIColor(
        red: 0.84,
        green: 0.08,
        blue: 0.25,
        alpha: 1
    )

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTile()
    }

    func update(title: String?, subtitle: String?, color: UIColor) {
        tileView.color = color
        tileView.title = title
        tileView.subtitle = subtitle
    }

    override func resetTile() {
        tileView.backgroundImageView.image = nil
        tileView.color = defaultTileColor
        tileView.title = ""
        tileView.subtitle = ""
    }

    func update(viewModel: ViewModel) {
        if let color = viewModel.color {
            tileView.color = color
        } else {
            tileView.color = defaultTileColor
        }
        tileView.title = viewModel.title
        tileView.subtitle = viewModel.subtitle
        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }
    }

    func setBackgroundColor(isCustomColor: Bool) {
        backgroundColor = isCustomColor
            ? backgroundTintColor
            : .white
    }
}
