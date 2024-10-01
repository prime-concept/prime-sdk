import UIKit

final class DetailRouteView: UIView {
    enum Description {
        static let start = "🚩\n"
        static let finish = "🏁\n"
    }

    @IBOutlet private weak var stackView: UIStackView!

    var onPlaceClick: ((Int) -> Void)?
    var onShareClick: ((Int) -> Void)?
    var onAddToFavoritesClick: ((Int) -> Void)?

    private var places: [ListItemViewModel] = []

    func setup(viewModel: DetailRoutePlacesViewModel) {
        func makeSeparatorView() -> DetailRouteSeparatorView {
            return .fromNib()
        }

        // Remove old route
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // Add start
        let startDirectionView: DetailRouteDirectionItemView = .fromNib()
        startDirectionView.update(
            description: "\(Description.start)\(viewModel.startRoute ?? "")"
        )
        stackView.addArrangedSubview(startDirectionView)

        // Separator
        stackView.addArrangedSubview(makeSeparatorView())

        // Items
        places.removeAll()

        for item in viewModel.items {
            switch item {
            case .direction(let description):
                let directionView: DetailRouteDirectionItemView = .fromNib()
                directionView.update(description: description)
                stackView.addArrangedSubview(directionView)
            case .place(let viewModel):
                places.append(viewModel)
                let placeView: DetailRoutePlaceItemView = .fromNib()
                placeView.onTap = { [weak self] index in
                    self?.onPlaceClick?(index - 1)
                }
                placeView.onShare = { [weak self] index in
                    self?.onShareClick?(index - 1)
                }
                placeView.onAddToFavorites = { [weak self] index in
                    self?.onAddToFavoritesClick?(index - 1)
                }
                placeView.update(with: viewModel, index: places.count)
                stackView.addArrangedSubview(placeView)
            }

            // Separator
            stackView.addArrangedSubview(makeSeparatorView())
        }

        // Add finish
        let finishDirectionView: DetailRouteDirectionItemView = .fromNib()
        finishDirectionView.update(
            description: "\(Description.finish)\(viewModel.endRoute ?? "")"
        )
        stackView.addArrangedSubview(finishDirectionView)

        layoutIfNeeded()
    }
}
