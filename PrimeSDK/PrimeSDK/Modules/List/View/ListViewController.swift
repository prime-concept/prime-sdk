import SnapKit
import UIKit
import YandexMobileAds

extension String {
    func height(with width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return boundingBox.height
    }
}

class ListViewController: AnyListView, UICollectionViewDataSource {
    var presenter: AnyListPresenter?
    let openModuleRoutingService = OpenModuleRoutingService()
    var viewModel = ListViewModel.empty

    override var shouldUsePagination: Bool {
        return super.shouldUsePagination &&
            (presenter?.canViewLoadNewPage ?? false)
    }

    override var viewController: UIViewController? {
        return self
    }

    override var shouldUsePullToRefresh: Bool {
        return presenter?.allowsPullToRefresh ?? false
    }

    private var state: ListViewState = .loading {
        didSet {
            switch state {
            case .normal:
                collectionView.isHidden = false
                emptyStateView?.isHidden = true
                refreshControl?.endRefreshing()
            case .loading:
                if let viewModel = presenter?.getDummyViewModel() {
                    update(viewModel: viewModel)
                }
                collectionView.isHidden = false
                emptyStateView?.isHidden = true
            case .empty:
                setupEmptyView(
                    with: NSLocalizedString("SearchNotFound", bundle: .primeSdk, comment: "")
                ) { [weak self] in
                    self?.presenter?.refresh()
                }
                collectionView.isHidden = false
                emptyStateView?.isHidden = false
                refreshControl?.endRefreshing()

            case .error(let text):
                setupEmptyView(with: text) { [weak self] in
                    self?.presenter?.refresh()
                }
                collectionView.isHidden = false
                emptyStateView?.isHidden = false
                refreshControl?.endRefreshing()
            }
        }
    }

    private var imageAd: YMANativeImageAd?
    private var didAdLoad: Bool {
        return imageAd != nil
    }

    private var adIndexPath = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *), prefersLargeTitles {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
        }

        self.setupNavigationItem()
        self.setupEmptyView()

        self.loadingIndicator.isHidden = true

        presenter?.listDelegate?.presented(by: self, for: presenter?.name ?? "")
        set(state: .loading)
        presenter?.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter?.willAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.didAppear()
    }

    private func setupEmptyView() {
        if let emtpyView = presenter?.listDelegate?.getEmtpyView(for: presenter?.name ?? "") {
            self.collectionView.addSubview(emtpyView)
            emtpyView.translatesAutoresizingMaskIntoConstraints = false

            emtpyView.attachEdges(to: self.collectionView, top: 0, left: 0, bottom: 0, right: 0)

            emtpyView.centerXAnchor.constraint(
                equalTo: self.collectionView.centerXAnchor,
                constant: 0
            ).isActive = true
            emtpyView.centerYAnchor.constraint(
                equalTo: self.collectionView.centerYAnchor,
                constant: 0
            ).isActive = true

            self.emptyStateView = emtpyView
        }
    }

    override func setupCollectionView() {
        super.setupCollectionView()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellClass: ListCollectionViewCell.self)
        collectionView.register(cellClass: CinemaCardCollectionViewCell.self)
        collectionView.register(cellClass: MovieNowCollectionViewCell.self)
        collectionView.register(cellClass: QuestsCollectionViewCell.self)

        if presenter?.hasHeader ?? false {
            collectionView.register(
                viewClass: ListHeaderView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
            )

            collectionView.register(
                viewClass: NewListHeaderView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
            )
        }

        collectionView.collectionViewLayout.invalidateLayout()
        let layout = SectionListFlowLayout(
            itemSizeType: presenter?.itemSizeType() ?? .bigSection
        )
        layout.sizeDelegate = self
        collectionView.setCollectionViewLayout(layout, animated: true)

        //TODO: need to know, what is it and maybe remove
        presenter?.listDelegate?.registerHeaderView(for: "routes-list", in: collectionView)
    }

    override func refreshData(_ sender: Any) {
        presenter?.refresh()
    }

    override func loadNextPage() {
        presenter?.loadNextPage()
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.viewModel.data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let itemViewModel = self.viewModel.data[indexPath.row]
        let cell = itemViewModel.makeCell(for: collectionView, indexPath: indexPath, listState: self.state)
        return cell
    }

    @objc(collectionView:didSelectItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if didAdLoad, indexPath == adIndexPath {
            return
        }

        presenter?.selectItem(at: indexPath.row)
    }

    @objc(collectionView:layout:referenceSizeForHeaderInSection:)
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if let height = presenter?.listDelegate?.getHeaderHeight(
            for: presenter?.name ?? ""
        ) {
            return CGSize(
                width: collectionView.frame.width,
                height: height
            )
        }

        if (presenter?.hasHeader ?? false), let header = self.viewModel.header {
            let descriptionHeight = header.description?.height(
                with: collectionView.frame.width - 30,
                font: .systemFont(ofSize: 16, weight: .semibold)
            ) ?? 0.0
            return CGSize(width: collectionView.frame.width, height: descriptionHeight + 250 + 25)
        }

        return .zero
    }

    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let header = presenter?.listDelegate?.getListHeader(
                for: presenter?.name ?? "",
                collectionView: collectionView,
                indexPath: indexPath,
                controller: self
            ) {
                return header
            }

            if (presenter?.hasHeader ?? false), let header = self.viewModel.header {
                let headerView: NewListHeaderView = collectionView
                    .dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        for: indexPath
                )
                headerView.setup(wtih: header)
                return headerView
            }
        }

        return super.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: kind,
            at: indexPath
        )
    }

    // MARK: - ListViewProtocol

    override func update(viewModel: ListViewModel) {
        self.viewModel = viewModel

        self.presenter?.listDelegate?.listUpdatedWithData(
            count: viewModel.data.count,
            for: presenter?.name ?? ""
        )

        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    override func open(
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

    override func set(state: ListViewState) {
        self.state = state
    }

    override func set(imageAd: YMANativeImageAd) {
        self.imageAd = imageAd
        collectionView.reloadData()
    }

    override func setPagination(state: PaginationState) {
        paginationState = state
    }

    override func setScrollIndicatorVisibilty(_ isHide: Bool) {
        collectionView.showsVerticalScrollIndicator = !isHide
    }

    override func reloadData() {
        collectionView.reloadData()
    }
}

extension ListViewController: ListFlowLayoutSizeDelegate {
    func heightFor(section: Int) -> CGFloat? {
        guard presenter?.supportAutoItemHeight ?? false else {
            return nil
        }

        guard let heightReportingCell = viewModel.data[section] as? HeightReportingListItemViewModelProtocol else {
            return nil
        }

        let height = heightReportingCell.height

        return height
    }
}
