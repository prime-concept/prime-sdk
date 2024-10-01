import Foundation

protocol NavigatorCitiesViewProtocol: class {
    func update(viewModel: NavigatorCitiesViewModel)
    func set(state: NavigatorCitiesViewState)
    func set(title: String?)
    var viewController: UIViewController { get }
}

enum NavigatorCitiesViewState {
    case data
    case empty
    case refreshing
    case error
    case loadingNewPage
    case errorLoadingNewPage

    var paginationState: PaginationState {
        switch self {
        case .loadingNewPage:
            return .loading
        case .errorLoadingNewPage:
            return .error
        default:
            return .none
        }
    }
}

class NavigatorCitiesViewController: UIViewController, NavigatorCitiesViewProtocol {
    var presenter: NavigatorCitiesPresenterProtocol?

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    var viewModel: NavigatorCitiesViewModel?
    var state: NavigatorCitiesViewState = .empty

    private var layout = HomeListFlowLayout(itemSizeType: .smallSection)
//    var paginationView: PaginationCollectionViewFooterView?
    var refreshControl: SpinnerRefreshControl?

    var viewController: UIViewController {
        return self
    }

    public init() {
        super.init(nibName: "NavigatorCitiesViewController", bundle: .primeSdk)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupRefreshControl()

        searchBar.delegate = self
        let panRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(onPan)
        )
        let appearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        appearance.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor(hex6: 0xEF3124)],
            for: .normal
        )

        collectionView.addGestureRecognizer(panRecognizer)
        panRecognizer.delegate = self

        presenter?.refresh()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func setupCollectionView() {
        collectionView.register(cellClass: HomeCollectionViewCell<NavigatorCityViewModel>.self)
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(
            viewClass: PaginationCollectionViewFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
        )
    }

    @objc
    func onPan() {
        view.endEditing(true)
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
    }

    @objc
    func refreshData(_ sender: Any) {
        presenter?.refresh()
    }

    func update(viewModel: NavigatorCitiesViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }

    func set(state: NavigatorCitiesViewState) {
        switch state {
        case .data:
            refreshControl?.endRefreshing()
            //TODO: Hide empty state and other things
        case .error:
            refreshControl?.endRefreshing()
            //TODO: Show some empty state here
        case .errorLoadingNewPage:
            break
        case .loadingNewPage:
            break
        case .refreshing:
            //TODO: Maybe show some skeleton here
            break
        case .empty:
            refreshControl?.endRefreshing()
            //TODO: Handle empty state
        }

//        paginationView?.set(state: state.paginationState)
    }

    func set(title: String?) {
        navigationController?.navigationBar.topItem?.title = title
    }
}

extension NavigatorCitiesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let city = viewModel?.cities[indexPath.section] {
            presenter?.select(city: city)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let viewModel = viewModel else {
            return
        }
        if indexPath.section + 1 == viewModel.cities.count {
            presenter?.loadNextPage()
//            paginationView?.set(state: .loading)
        }
    }
}

extension NavigatorCitiesViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        referenceSizeForFooterInSection section: Int
//    ) -> CGSize {
////        guard shouldUsePagination else {
////            return CGSize.zero
////        }
//        guard section + 1 == viewModel?.cities.count else {
//            return CGSize.zero
//        }
//
//        return CGSize(
//            width: collectionView.bounds.width,
//            height: 65
//        )
//    }
}


extension NavigatorCitiesViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: HomeCollectionViewCell<NavigatorCityViewModel> = collectionView.dequeueReusableCell(for: indexPath)
        if let city = viewModel?.cities[indexPath.section] {
            cell.update(viewModel: city)
        }
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.cities.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

//    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)
//    func collectionView(
//        _ collectionView: UICollectionView,
//        viewForSupplementaryElementOfKind kind: String,
//        at indexPath: IndexPath
//    ) -> UICollectionReusableView {
//        if kind == UICollectionView.elementKindSectionFooter {
//            let view: PaginationCollectionViewFooterView = collectionView
//                .dequeueReusableSupplementaryView(
//                    ofKind: UICollectionView.elementKindSectionFooter,
//                    for: indexPath
//            )
//
//            self.paginationView = view
//            return view
//        } else {
//            fatalError("Unsupported view")
//        }
//    }
}

extension NavigatorCitiesViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            presenter?.changeQuery(toQuery: nil)
        } else {
            presenter?.changeQuery(toQuery: searchText)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        presenter?.changeQuery(toQuery: nil)
    }
}

extension NavigatorCitiesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
