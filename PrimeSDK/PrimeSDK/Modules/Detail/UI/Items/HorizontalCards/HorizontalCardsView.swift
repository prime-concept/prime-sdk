import UIKit

final class DetailHorizontalCardsView: UIView, ProgrammaticallyDesignable {
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = .init(width: 340, height: 96)
        collectionViewLayout.minimumLineSpacing = 10
        collectionViewLayout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.register(cellClass: DetailHorizontalCardCollectionViewCell.self)
        view.dataSource = self
        view.backgroundColor = .white
        view.contentInset = .init(top: 0, left: 15, bottom: 10, right: 15)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: 0x808080)
        label.isHidden = true
        return label
    }()

    private var items = [ListItemViewModel]()

    init() {
        super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
        self.setupFonts()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Setup view parameters (e.g. set colors, fonts, etc)
    func setupView() {
    }

    /// Set up subviews hierarchy
    func addSubviews() {
        self.addSubview(self.collectionView)
        self.addSubview(self.titleLabel)
    }

    /// Add constraints
    func makeConstraints() {
        self.collectionView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.height.equalTo(96 + 10 + 5)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalTo(self.collectionView.snp.top).offset(-15)
        }
    }

    func setup(viewModel: DetailHorizontalItemsViewModel) {
        self.items = viewModel.items
        self.titleLabel.text = viewModel.title
        self.titleLabel.isHidden = viewModel.title.isEmpty || viewModel.items.isEmpty
        self.collectionView.reloadData()
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 12, weight: .medium)
    }
}

extension DetailHorizontalCardsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: DetailHorizontalCardCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.itemView.setup(model: self.items[indexPath.item])
        return cell
    }
}
