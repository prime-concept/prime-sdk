import UIKit

final class DetailRoutePlaceItemView: UIView {
    private static let defaultTileColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    private static let indexBackgroundColor = UIColor(red: 0.15, green: 0.14, blue: 0.38, alpha: 1)

    private var isInit: Bool = false

    private lazy var tileView: ActionTileView = .fromNib()
    @IBOutlet private weak var indexLabel: PaddingLabel!

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(self.onItemClicked)
    )

    private var currentIndex: Int?
    var onTap: ((Int) -> Void)?
    var onShare: ((Int) -> Void)?
    var onAddToFavorites: ((Int) -> Void)?

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 230)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.indexLabel.font = UIFont.font(of: 12, weight: .semibold)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInit {
            addGestureRecognizer(tapGestureRecognizer)

            isInit = true

            tileView.cornerRadius = 15
            tileView.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(tileView, belowSubview: indexLabel)

            tileView.topAnchor.constraint(
                equalTo: self.topAnchor
            ).isActive = true
            tileView.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 15
            ).isActive = true
            tileView.bottomAnchor.constraint(
                equalTo: self.bottomAnchor,
                constant: -10
            ).isActive = true
            tileView.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -15
            ).isActive = true
        }

        invalidateIntrinsicContentSize()
    }

    func update(with viewModel: ListItemViewModel, index: Int) {
        currentIndex = index

        indexLabel.backgroundColor = DetailRoutePlaceItemView.indexBackgroundColor
        indexLabel.text = "\(index)"

        tileView.color = DetailRoutePlaceItemView.defaultTileColor

        tileView.title = viewModel.title
        tileView.subtitle = viewModel.subtitle

        tileView.isFavoriteButtonHidden = false
        tileView.isFavoriteButtonSelected = viewModel.isFavorite

        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }

        tileView.leftTopText = nil

        tileView.viewModel = viewModel
    }

    @objc
    private func onItemClicked() {
        if let index = currentIndex {
            onTap?(index)
        }
    }
}

