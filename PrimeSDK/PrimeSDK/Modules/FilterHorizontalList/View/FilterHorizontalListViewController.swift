import Foundation
import SnapKit

protocol FilterHorizontalListViewProtocol: class {
    var presenter: FilterHorizontalListPresenterProtocol? { get }
    func update(viewModel: FilterHorizontalListViewModel)
    func open(
        model: ViewModelProtocol?,
        action: OpenModuleConfigAction,
        config: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    )
}

class FilterHorizontalListViewController: UIViewController,
    FilterHorizontalListViewProtocol, UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleLabelLeading: NSLayoutConstraint!
    @IBOutlet private weak var allButton: UIButton!
    @IBOutlet private weak var allButtonTrailing: NSLayoutConstraint!
    var presenter: FilterHorizontalListPresenterProtocol?
    var viewModel: FilterHorizontalListViewModel?
    var openModuleRoutingService = OpenModuleRoutingService()

    var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }

    convenience init() {
        self.init(nibName: "TitledHorizontalListViewController", bundle: .primeSdk)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        presenter?.refresh()
    }

    private func setupCollectionView() {
        collectionView.register(cellClass: FilterItemCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // MARK: - FilterHorizontalListViewProtocol
    func update(viewModel: FilterHorizontalListViewModel) {
        self.viewModel = viewModel
        self.titleText = viewModel.title

        titleLabel.isHidden = !viewModel.showTitle
        allButton.isHidden = true

        collectionViewHeight.constant = CGFloat(viewModel.itemHeight)
        collectionView.reloadData()
    }

    func open(
        model: ViewModelProtocol?,
        action: OpenModuleConfigAction,
        config: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        openModuleRoutingService.route(
            using: model,
            openAction: action,
            from: self,
            configuration: config,
            sdkManager: sdkManager
        )
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let items = viewModel?.items,
            indexPath.item < items.count
        else {
            return
        }
        presenter?.didSelect(item: items[indexPath.item])
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            return 0
        }
        return viewModel.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let viewModel = viewModel else {
            return UICollectionViewCell()
        }

        let cell: FilterItemCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.update(with: viewModel.items[indexPath.item])

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard
            let items = viewModel?.items,
            indexPath.item < items.count,
            let height = viewModel?.itemHeight
        else {
            return CGSize.zero
        }
        let item = items[indexPath.item]

        return CGSize(
            width: item.title.width(
                withConstrainedHeight: CGFloat(height),
                font: UIFont.font(of: 16, weight: .bold)
            ) + 30,
            height: CGFloat(height)
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        guard let spacing = viewModel?.spacing else {
            return 0
        }
        return CGFloat(spacing)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        guard let spacing = viewModel?.spacing else {
            return 0
        }
        return CGFloat(spacing)
    }
}
