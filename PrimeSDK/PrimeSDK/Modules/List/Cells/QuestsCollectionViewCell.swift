import Foundation

final class QuestsCollectionViewCell: TileCollectionViewCell<
    QuestTileView, QuestItemViewModel
>, ViewReusable, FavoritableCellProtocol, ShareableCellProtocol {
    var onAddToFavoriteButtonClick: (() -> Void)?
    var onShareButtonClick: (() -> Void)?
    private static let defaultTintColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)

    var onShareButtonTouch: (() -> Void)?

    override func resetTile() {
        tileView.title = ""
        tileView.placeDescription = ""
        tileView.leftTopText = ""
        tileView.pointsDescription = ""
    }

    override func update(with viewModel: QuestItemViewModel) {
        tileView.title = viewModel.title
        tileView.placeDescription = viewModel.place
        tileView.leftTopText = viewModel.leftTopText
        tileView.pointsDescription = "+\(viewModel.reward) баллов"
        if let imageURL = viewModel.imageURL {
            tileView.loadImage(from: imageURL)
        }
        if let color = viewModel.color {
            tileView.color = color
        }
        tileView.color = .clear
        tileView.status = viewModel.questState
        tileView.onShareTap = { [weak self] in
            self?.onShareButtonTouch?()
        }
    }
    func setFavorite(to: Bool) {
    }
}
