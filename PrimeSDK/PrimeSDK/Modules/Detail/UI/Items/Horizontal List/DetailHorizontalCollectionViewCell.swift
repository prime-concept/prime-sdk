import UIKit

final class DetailHorizontalCollectionViewCell: TileCollectionViewCell<LabeledTileView, ListItemViewModel>,
ViewReusable {
    private static let defaultTileColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)

    override var needsShadow: Bool {
        return false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTile()
    }

    func update(title: String?, color: UIColor) {
        tileView.color = color
        tileView.title = title
    }

    override func resetTile() {
        tileView.color = DetailHorizontalCollectionViewCell.defaultTileColor
        tileView.title = ""
    }

    override func update(with viewModel: ListItemViewModel) {
        tileView.leftTopText = viewModel.leftTopText
        tileView.title = viewModel.title
        tileView.color = DetailHorizontalCollectionViewCell.defaultTileColor

        if let imageURL = viewModel.imageURL {
            tileView.loadImage(from: imageURL)
        }
    }
}
