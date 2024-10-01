import UIKit

fileprivate extension CGFloat {
    static let searchBottomMarginLarge: CGFloat = 18
    static let searchBottomMarginSmall: CGFloat = 12
    static let navigationBarHeightSmall: CGFloat = 44
    static let navigationBarHeightLarge: CGFloat = 96.5
}

class CollectionViewController: UIViewController {
    var emptyStateView: UIView?
    var refreshControl: SpinnerRefreshControl?

    private(set) var prefersLargeTitles = false

    @IBOutlet weak var loadingIndicator: SpinnerView!
    @IBOutlet weak var collectionView: UICollectionView!

    var paginationState: PaginationState = .none {
        didSet {
            paginationView?.set(state: paginationState)
        }
    }

    var shouldUsePagination: Bool {
        return true
    }

    var shouldUsePullToRefresh: Bool {
        return true
    }

    var paginationView: PaginationCollectionViewFooterView?

    lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(
            self,
            action: #selector(searchButtonClicked),
            for: .touchUpInside
        )
        button.setImage(UIImage(named: "search"), for: .normal)

        return button
    }()

    convenience init() {
        self.init(nibName: "CollectionViewController", bundle: .primeSdk)
    }

    convenience init(prefersLargeTitles: Bool) {
        self.init(nibName: "CollectionViewController", bundle: .primeSdk)
        self.prefersLargeTitles = prefersLargeTitles
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        if shouldUsePullToRefresh {
            setupRefreshControl()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func setupCollectionView() {
        collectionView.clipsToBounds = false
        collectionView.register(
            viewClass: PaginationCollectionViewFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
        )
        collectionView.delegate = self
    }

    private func setupRefreshControl() {
        let refreshControl = SpinnerRefreshControl()
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
        self.refreshControl?.layer.zPosition = -1
    }

    func setupEmptyView(with text: String, retryAction: @escaping () -> Void) {
//        switch type {
//        case .favorites, .tickets:
//            let view: EmptyStateCustomView = .fromNib()
//            view.setup(with: type)
//            view.translatesAutoresizingMaskIntoConstraints = false
//            collectionView.addSubview(view)
//            view.alignToSuperview()
//            self.emptyStateView = view
//        default:
        let view: EmptyStateView = .fromNib()
        view.retryAction = retryAction
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = text
        collectionView.addSubview(view)
        view.align()
        self.emptyStateView = view
//        }
    }

    @objc
    func refreshData(_ sender: Any) {
    }

    func loadNextPage() {
    }

    func setupNavigationItem() {
        if #available(iOS 11.0, *), prefersLargeTitles {
            setupNavigationItemAsButton()
        } else {
            let rightButton = UIBarButtonItem(
                image: UIImage(named: "search", in: .primeSdk, compatibleWith: nil),
                style: .plain,
                target: self,
                action: #selector(searchButtonClicked)
            )
            navigationItem.rightBarButtonItem = rightButton
        }
    }

    private func setupNavigationItemAsButton() {
        guard
            let navigationBar = navigationController?.navigationBar
        else {
            return
        }
        navigationBar.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                searchButton.rightAnchor.constraint(
                    equalTo: navigationBar.rightAnchor,
                    constant: -14
                ),
                searchButton.bottomAnchor.constraint(
                    equalTo: navigationBar.bottomAnchor,
                    constant: -.searchBottomMarginLarge
                ),
                searchButton.heightAnchor.constraint(equalToConstant: 17),
                searchButton.widthAnchor.constraint(equalToConstant: 17)
            ]
        )
    }

    private func moveSearchButton(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - .navigationBarHeightSmall
            let navigationBarHeightDiff = .navigationBarHeightLarge - .navigationBarHeightSmall
            return delta / navigationBarHeightDiff
        }()

        let yTranslation: CGFloat = {
            let maxYTranslation = .searchBottomMarginLarge - .searchBottomMarginSmall
            return max(
                0,
                min(
                    maxYTranslation,
                    maxYTranslation - coeff * .searchBottomMarginSmall
                )
            )
        }()

        searchButton.transform = CGAffineTransform.identity.translatedBy(x: 0, y: yTranslation)
    }

    @objc
    private func searchButtonClicked() {
        presentSearch()
    }

    func presentSearch(focusOnSearchBar: Bool = false) {
//        push(module: SearchAssembly(focusOnSearchBar: focusOnSearchBar).buildModule())
    }
}

extension CollectionViewController: UICollectionViewDelegate {
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
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard shouldUsePagination, paginationState != .loading else {
            return
        }

        let count = collectionView.numberOfItems(inSection: indexPath.section)
        if indexPath.row + 1 == count {
            paginationState = .loading
            loadNextPage()
        }
    }

    // Using @objc notation cause we cannot implement other DataSource methods here
    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let view: PaginationCollectionViewFooterView = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    for: indexPath
            )
            view.loadNextBlock = { [weak self] in
                self?.loadNextPage()
            }
            view.set(state: self.paginationState)
            self.paginationView = view
            return view
        }

        fatalError("Unsupported view")
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.refreshControl?.updateScrollState()
        guard
            let height = navigationController?.navigationBar.frame.height
        else {
            return
        }
        moveSearchButton(for: height)
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard shouldUsePagination else {
            return CGSize.zero
        }

        return CGSize(
            width: collectionView.bounds.width,
            height: 65
        )
    }
}
