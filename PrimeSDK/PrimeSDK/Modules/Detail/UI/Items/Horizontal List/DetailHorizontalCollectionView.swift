import UIKit

final class DetailHorizontalCollectionView: DetailBaseCollectionView {
    @IBOutlet private weak var titleLabel: UILabel!

    /// Clicked cell with given DetailHorizontalItemViewModel
    var onCellClick: ((ListItemViewModel) -> Void)?

    var data: [ListItemViewModel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.showsHorizontalScrollIndicator = false

//        titleLabel.text = "Blabla"//LS.localize("RestaurantsNearby")
        self.titleLabel.font = UIFont.font(of: 12, weight: .semibold)

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.isUserInteractionEnabled = true
        collectionView.register(cellClass: DetailHorizontalCollectionViewCell.self)
    }

    func setup(viewModel: DetailHorizontalItemsViewModel) {
        titleLabel.text = viewModel.title
        self.data = viewModel.items
        set(
            layout: DetailHorizontalListFlowLayout(
                itemSizeType: viewModel.itemSize
            )
        )
        collectionView.reloadData()
    }

    func set(layout: UICollectionViewLayout) {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    func set(items: [ListItemViewModel]) {
        self.data = items
        collectionView.reloadData()
    }
}

extension DetailHorizontalCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: DetailHorizontalCollectionViewCell = collectionView.dequeueReusableCell(
            for: indexPath
        )
        let viewModel = data[indexPath.row]
        cell.update(with: viewModel)
        return cell
    }
}

extension DetailHorizontalCollectionView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didHighlightItemAt indexPath: IndexPath
    ) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ViewHighlightable {
            cell.highlight()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didUnhighlightItemAt indexPath: IndexPath
    ) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ViewHighlightable {
            cell.unhighlight()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let viewModel = data[indexPath.row]
        onCellClick?(viewModel)
    }
}

extension DetailHorizontalCollectionView: UICollectionViewDelegateFlowLayout {
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//        return CGSize(width: 110, height: 110)
//    }
}
