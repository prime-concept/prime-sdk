import Foundation

final class CinemaTableViewCell: TileTableViewCell<
    CinemaTileView, CinemaCardViewModel
>, ViewReusable {
    var isSkeletonShown: Bool = false {
        didSet {
            tileView.isSkeletonShown = isSkeletonShown
        }
    }
    override func update(with viewModel: CinemaCardViewModel) {
        tileView.setup(viewModel: viewModel)
        tileView.shadowRadius = 4
        tileView.color = UIColor.black.withAlphaComponent(0.12)
        tileView.shadowOffset = CGSize(width: 0, height: 3)
        tileView.backgroundColor = .white
    }

    override func resetTile() {
        tileView.reset()
    }
}
