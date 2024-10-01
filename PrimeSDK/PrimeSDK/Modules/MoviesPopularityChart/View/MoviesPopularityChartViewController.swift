import SkeletonView
import UIKit

protocol MoviesPopularityChartViewProtocol: class {
    func update(viewModel: MoviesPopularityChartViewModel)
    func setLoading(isLoading: Bool)
    func open(
        model: ViewModelProtocol?,
        action: OpenModuleConfigAction,
        config: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    )
}

class MoviesPopularityChartViewController: UIViewController, MoviesPopularityChartViewProtocol {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private var titleLabelLeading: NSLayoutConstraint!

    @IBOutlet private weak var allButton: UIButton!
    @IBOutlet weak var allButtonTrailing: NSLayoutConstraint!

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeight: NSLayoutConstraint!

    var presenter: MoviesPopularityChartPresenterProtocol?
    var viewModel: MoviesPopularityChartViewModel?
    var openModuleRoutingService = OpenModuleRoutingService()

    var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }

    var isLoading: Bool = false

    convenience init() {
        self.init(nibName: "TitledHorizontalListViewController", bundle: .primeSdk)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        presenter?.refresh()
        collectionView.register(cellClass: MoviesPopularityChartCollectionViewCell.self)
    }

    // MARK: - MoviesPopularityChartViewProtocol
    func update(viewModel: MoviesPopularityChartViewModel) {
        self.viewModel = viewModel
        self.titleText = viewModel.title

        titleLabel.isHidden = !viewModel.showTitle
        allButton.isHidden = true
        if viewModel.items.isEmpty, !viewModel.isDummy {
            self.view.isHidden = true
            self.removeFromParent()
        }
        collectionViewHeight.constant = CGFloat(viewModel.viewHeight)
        collectionView.reloadData()
    }

    func setLoading(isLoading: Bool) {
        self.isLoading = isLoading
        if isLoading, let viewModel = presenter?.loadingViewModel {
            update(viewModel: viewModel)
        }
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
}

// MARK: - UICollectionViewDelegate
extension MoviesPopularityChartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let items = viewModel?.items,
            indexPath.item < items.count
        else {
            return
        }
        presenter?.didSelect(item: items[indexPath.item])
    }
}

// MARK: - UICollectionViewDataSource
extension MoviesPopularityChartViewController: UICollectionViewDataSource {
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

        let cell: MoviesPopularityChartCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.isSkeletonShown = isLoading
        cell.update(with: viewModel.items[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MoviesPopularityChartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let height = viewModel?.itemHeight, let width = viewModel?.itemWidth else {
            return CGSize.zero
        }
        return CGSize(width: Double(width), height: Double(height))
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
