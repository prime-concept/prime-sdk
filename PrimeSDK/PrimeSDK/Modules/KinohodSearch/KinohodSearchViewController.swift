import Foundation
import SkeletonView

protocol KinohodSearchViewProtocol: AnyObject {
    func update(viewModel: KinohodSearchViewModel)
    func setLoading(isLoading: Bool)
    func open(
        model: ViewModelProtocol,
        action: OpenModuleConfigAction,
        config: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    )
}

class KinohodSearchViewController: UIViewController, KinohodSearchViewProtocol {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    @IBOutlet weak var cinemasCollectionView: UICollectionView!
    @IBOutlet weak var moviesLabel: UILabel!
    @IBOutlet weak var cinemasLabel: UILabel!
    @IBOutlet weak var searchTitleLabel: UILabel!

    @IBOutlet weak var moviesTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cinemasTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!

    let activePriority = UILayoutPriority(999)
    let inactivePriority = UILayoutPriority(998)

    var presenter: KinohodSearchPresenterProtocol?

    var viewModel: KinohodSearchViewModel?
    let openModuleRoutingService = OpenModuleRoutingService()

    var isLoading: Bool = false

    convenience init() {
        self.init(nibName: "KinohodSearchViewController", bundle: .primeSdk)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMoviesCollectionView()
        setupCinemasCollectionView()

        searchBar.delegate = self

        let panRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(onPan)
        )
        scrollView.addGestureRecognizer(panRecognizer)
        panRecognizer.delegate = self

        presenter?.changeQuery(toQuery: nil)

        self.setupFonts()
    }

    @objc
    private func onPan() {
        view.endEditing(true)
    }

    private func setupFonts() {
        self.searchTitleLabel.font = UIFont.font(of: 20, weight: .bold)
        self.moviesLabel.font = UIFont.font(of: 20, weight: .bold)
        self.cinemasLabel.font = UIFont.font(of: 20, weight: .bold)
        self.emptyStateLabel.font = UIFont.font(of: 16)
    }

    func setLoading(isLoading: Bool) {
        self.isLoading = isLoading
        if isLoading, let viewModel = presenter?.loadingViewModel {
            update(viewModel: viewModel)
        } else if !isLoading {
            defineEmptyStateText()
            self.emptyStateView.isHidden = false
        }
    }

    private func defineEmptyStateText() {
        if (self.viewModel?.query ?? "").count < 2 {
            emptyStateLabel.text = NSLocalizedString("SearchStartState", bundle: .primeSdk, comment: "")
        } else {
            emptyStateLabel.text = NSLocalizedString("SearchEmptyState", bundle: .primeSdk, comment: "")
        }
    }

    private func setMovies(hidden: Bool) {
        moviesLabel.isHidden = hidden
        moviesCollectionView.isHidden = hidden
    }

    private func setCinemas(hidden: Bool) {
        cinemasLabel.isHidden = hidden
        cinemasCollectionView.isHidden = hidden
    }

    func update(viewModel: KinohodSearchViewModel) {
        self.viewModel = viewModel

        if viewModel.movies.isEmpty && viewModel.cinemas.isEmpty {
            setMovies(hidden: true)
            setCinemas(hidden: true)
            defineEmptyStateText()
            emptyStateView.isHidden = false
        }
        if viewModel.movies.isEmpty && !viewModel.cinemas.isEmpty {
            setMovies(hidden: true)
            setCinemas(hidden: false)
            moviesTopConstraint.priority = inactivePriority
            cinemasTopConstraint.priority = activePriority
            self.emptyStateView.isHidden = true
        }
        if !viewModel.movies.isEmpty && viewModel.cinemas.isEmpty {
            setMovies(hidden: false)
            setCinemas(hidden: true)
            moviesTopConstraint.priority = activePriority
            cinemasTopConstraint.priority = inactivePriority
            self.emptyStateView.isHidden = true
        }
        if !viewModel.movies.isEmpty && !viewModel.cinemas.isEmpty {
            setMovies(hidden: false)
            setCinemas(hidden: false)
            moviesTopConstraint.priority = activePriority
            cinemasTopConstraint.priority = inactivePriority
            self.emptyStateView.isHidden = true
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()

        reload()
    }

    private func reload() {
        moviesCollectionView.reloadData()
        cinemasCollectionView.reloadData()
    }

    private func setupMoviesCollectionView() {
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        moviesCollectionView.register(cellClass: HomeMoviePlainCardCollectionViewCell.self)
    }

    private func setupCinemasCollectionView() {
        cinemasCollectionView.delegate = self
        cinemasCollectionView.dataSource = self
        cinemasCollectionView.register(cellClass: CinemaCardCollectionViewCell.self)
    }
}

extension KinohodSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if viewModel != nil {
            return 1
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            return 0
        }
        if collectionView == moviesCollectionView {
            return viewModel.movies.count
        } else if collectionView == cinemasCollectionView {
            return viewModel.cinemas.count
        } else {
            return 0
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let viewModel = viewModel else {
            return UICollectionViewCell()
        }

        if collectionView == moviesCollectionView {
            let movie = viewModel.movies[indexPath.item]
            let cell: HomeMoviePlainCardCollectionViewCell = moviesCollectionView.dequeueReusableCell(for: indexPath)
            cell.isSkeletonShown = isLoading
            cell.update(with: movie)
            return cell
        } else if collectionView == cinemasCollectionView {
            let cinema = viewModel.cinemas[indexPath.item]
            let cell: CinemaCardCollectionViewCell = cinemasCollectionView.dequeueReusableCell(for: indexPath)
            cell.isSkeletonShown = isLoading
            cell.update(with: cinema)
            return cell
        }

        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if
            collectionView == moviesCollectionView,
            let movie = viewModel?.movies[indexPath.item]
        {
            presenter?.didSelectMovie(movie: movie)
        } else if
            collectionView == cinemasCollectionView,
            let cinema = viewModel?.cinemas[indexPath.item]
        {
            presenter?.didSelectCinema(cinema: cinema)
        }
    }

    func open(
        model: ViewModelProtocol,
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

extension KinohodSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == moviesCollectionView {
            return CGSize(width: 135, height: 223)
        } else if collectionView == cinemasCollectionView {
            let width = cinemasCollectionView.bounds.width - 35
            return CGSize(width: width, height: 77)
        } else {
            return CGSize.zero
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == moviesCollectionView {
            return 10
        } else if collectionView == cinemasCollectionView {
            return 1
        } else {
            if #available(iOS 11, *) {
                return CGFloat.leastNonzeroMagnitude
            }
            return 1.1
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == moviesCollectionView {
            return 10
        } else if collectionView == cinemasCollectionView {
            return 1
        } else {
            if #available(iOS 11, *) {
                return CGFloat.leastNonzeroMagnitude
            }
            return 1.1
        }
    }
}

extension KinohodSearchViewController: UISearchBarDelegate {
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

extension KinohodSearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
