import UIKit

final class DetailSectionCollectionView<
    Cell: AnyUpdatableCollectionViewCell<ListItemViewModel>>: UIView,
    UICollectionViewDelegate, UICollectionViewDataSource
where Cell: ViewReusable {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = false
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(cellClass: Cell.self)
        return collectionView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 12, weight: .semibold)
        label.textColor = UIColor(
            red: 0.75,
            green: 0.75,
            blue: 0.75,
            alpha: 1
        )
        label.backgroundColor = UIColor.clear
        return label
    }()

    private var backgroundViewHeighConstraint: NSLayoutConstraint?

    private var previousCollectionViewHeight: CGFloat = 0
    private var previousCollectionViewWidth: CGFloat = 0

    var onLayoutUpdate: (() -> Void)?
    var onCellClick: ((ListItemViewModel) -> Void)?
    var onCellAddButtonTap: ((ListItemViewModel) -> Void)?

    private var items: [ListItemViewModel] = []

    private var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear

        addSubview(titleLabel)
        addSubview(backgroundView)
        backgroundView.addSubview(collectionView)

        addTitleLabelConstraints()
        addBackgroundViewConstraints()
        addCollectionViewConstraints()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if previousCollectionViewWidth != bounds.width {
            collectionView.collectionViewLayout.invalidateLayout()

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                let newHeight = strongSelf
                    .collectionView
                    .collectionViewLayout
                    .collectionViewContentSize
                    .height

                if strongSelf.previousCollectionViewHeight != newHeight {
                    strongSelf.previousCollectionViewHeight = newHeight

                    strongSelf.backgroundViewHeighConstraint?.constant = newHeight
                    strongSelf.onLayoutUpdate?()
                }
            }
        }
    }

    private func addTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                titleLabel.topAnchor.constraint(
                    equalTo: topAnchor,
                    constant: 15
                ),
                titleLabel.leftAnchor.constraint(
                    equalTo: leftAnchor,
                    constant: 15
                ),
                titleLabel.rightAnchor.constraint(
                    equalTo: rightAnchor,
                    constant: -15
                ),
                titleLabel.bottomAnchor.constraint(
                    equalTo: backgroundView.topAnchor,
                    constant: -5
                )
            ]
        )
    }

    private func addBackgroundViewConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                backgroundView.leftAnchor.constraint(
                    equalTo: leftAnchor
                ),
                backgroundView.rightAnchor.constraint(
                    equalTo: rightAnchor
                ),
                backgroundView.bottomAnchor.constraint(
                    equalTo: bottomAnchor,
                    constant: -10
                )
            ]
        )
        backgroundViewHeighConstraint = backgroundView.heightAnchor.constraint(
            equalToConstant: 150
        )
        backgroundViewHeighConstraint?.isActive = true
    }

    private func addCollectionViewConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                collectionView.topAnchor.constraint(
                    equalTo: backgroundView.topAnchor
                ),
                collectionView.leftAnchor.constraint(
                    equalTo: backgroundView.leftAnchor
                ),
                collectionView.rightAnchor.constraint(
                    equalTo: backgroundView.rightAnchor
                ),
                collectionView.bottomAnchor.constraint(
                    equalTo: backgroundView.bottomAnchor
                )
            ]
        )
    }

    func setup(viewModel: DetailVerticalItemsViewModel) {
        self.items = viewModel.items
        self.title = viewModel.title
        collectionView.reloadData()
    }

    func set(layout: UICollectionViewLayout) {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        var cell: Cell = collectionView.dequeueReusableCell(
            for: indexPath
        )
        let item = items[indexPath.row]
        cell.update(with: item)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let viewModel = items[indexPath.row]
        onCellClick?(viewModel)
    }
}
