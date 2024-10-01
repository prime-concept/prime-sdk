import UIKit

class HomeSelectionCardCollectionViewCell: UICollectionViewCell, ViewReusable {
    lazy var selectionCard: HomeSelectionCard = {
        let card = HomeSelectionCard()
        return card
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    private func addSubviews() {
        contentView.addSubview(selectionCard)
    }

    private func makeConstraints() {
        selectionCard.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    var isSkeletonShown: Bool = false {
        didSet {
            selectionCard.isSkeletonShown = isSkeletonShown
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with viewModel: HomeSelectionCardViewModel) {
        self.selectionCard.update(with: viewModel)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.selectionCard.update(with: nil)
    }
}
