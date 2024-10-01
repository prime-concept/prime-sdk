import UIKit

protocol TitledHorizontalListViewProtocol: class {
    func update(viewModel: TitledHorizontalListViewModel)
    func setLoading(isLoading: Bool)
    func open(
        model: ViewModelProtocol?,
        action: OpenModuleConfigAction,
        config: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    )
}

class TitledHorizontalListViewController: UIViewController, TitledHorizontalListViewProtocol {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelLeading: NSLayoutConstraint!

    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var allButtonTrailing: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    var presenter: TitledHorizontalListPresenterProtocol?

    var viewModel: TitledHorizontalListViewModel?
    var themeProvider: ThemeProvider?

    var openModuleRoutingService = OpenModuleRoutingService()

    var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }

    var count: Int? {
        didSet {
            let allString = NSLocalizedString("All", bundle: .primeSdk, comment: "")
            if let count = count {
                allButton.setTitle("\(allString) \(count)", for: .normal)
            } else {
                allButton.setTitle(allString, for: .normal)
            }
        }
    }

    var isLoading: Bool = false

    convenience init() {
        self.init(nibName: "TitledHorizontalListViewController", bundle: .primeSdk)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.themeProvider = ThemeProvider(themeUpdatable: self)

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(cellClass: HomeMoviePlainCardCollectionViewCell.self)
        self.collectionView.register(cellClass: HomeSelectionCardCollectionViewCell.self)
        self.collectionView.register(cellClass: ListCollectionViewCell.self)
        self.setupFonts()

        self.presenter?.didLoad()
    }

    func setLoading(isLoading: Bool) {
        self.isLoading = isLoading
        if isLoading, let viewModel = presenter?.loadingViewModel {
            update(viewModel: viewModel)
        }
    }

    func update(viewModel: TitledHorizontalListViewModel) {
        self.viewModel = viewModel
        self.titleText = viewModel.title
        self.titleLabel.textColor = viewModel.titleColor
        self.allButton.setTitleColor(viewModel.allColor, for: .normal)

        self.count = viewModel.count

        titleLabel.isHidden = !viewModel.showTitle
        allButton.isHidden = !viewModel.shouldShowAllButton

        if viewModel.count == nil, viewModel.items.isEmpty, !viewModel.isDummy {
            self.view.isHidden = true
            self.removeFromParent()
        }
        collectionViewHeight.constant = CGFloat(viewModel.itemHeight)
        titleLabelLeading.constant = CGFloat(viewModel.sideInsets)
        allButtonTrailing.constant = CGFloat(viewModel.sideInsets)
        let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsets(
            top: 0,
            left: CGFloat(viewModel.sideInsets),
            bottom: 0,
            right: CGFloat(viewModel.sideInsets)
        )
        collectionViewLayout?.invalidateLayout()

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

    @IBAction func allPressed(_ sender: Any) {
        presenter?.tapAll()
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 20, weight: .bold)
        self.allButton.titleLabel?.font = UIFont.font(of: 16, weight: .semibold)
    }
}

extension TitledHorizontalListViewController: UICollectionViewDelegate {
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

extension TitledHorizontalListViewController: UICollectionViewDataSource {
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
        if let items = viewModel?.items as? [HomeMoviePlainCardViewModel] {
            let cell: HomeMoviePlainCardCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.isSkeletonShown = isLoading
            cell.update(with: items[indexPath.item])
            return cell
        }

        if let items = viewModel?.items as? [HomeSelectionCardViewModel] {
            let cell: HomeSelectionCardCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.isSkeletonShown = isLoading
            cell.update(with: items[indexPath.item])
            return cell
        }

        if let items = viewModel?.items as? [ListItemViewModel] {
            let cell: ListCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.isSkeletonShown = isLoading
            cell.update(with: items[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
}

extension TitledHorizontalListViewController: UICollectionViewDelegateFlowLayout {
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

extension TitledHorizontalListViewController: ThemeUpdatable {
    func update(with theme: Theme) {
        self.allButton.setTitleColor(theme.palette.accent, for: .normal)
    }
}
