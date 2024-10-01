// swiftlint:disable file_length
import FloatingPanel
import Foundation

class DetailModuleViewController: DetailViewController, DetailViewProtocol {
    var viewModel = DetailViewModel.empty

    var presenter: DetailPresenterProtocol?

    private lazy var customBottomButton: BookingButton = {
        let button = BookingButton(type: .system)
        return button
    }()

    override var bottomButton: BookingButton? {
        return customBottomButton
    }

    private var scheduleButton: UIButton?

    //Bottom Panel
    private var bottomPanelTopConstraint: NSLayoutConstraint?
    private lazy var bottomPanelPadView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var bottomPanel: DetailBottomPanelView = {
        let view: DetailBottomPanelView = .fromNib()
        let recognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.hideBottomPanel)
        )
        view.addGestureRecognizer(recognizer)
        recognizer.direction = .down
        return view
    }()

    private lazy var bottomPanelDimView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor(
            red: 0.02,
            green: 0.02,
            blue: 0.06,
            alpha: 0.4
        )

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.hideBottomPanel)
        )
        view.addGestureRecognizer(tapRecognizer)
        return view
    }()

    private var detailLocationView: DetailLocationView?

    private var isLoading: Bool = false
    private var themeProvider: ThemeProvider?

    public init() {
        super.init(nibName: "DetailViewController", bundle: .primeSdk)
        self.themeProvider = ThemeProvider(themeUpdatable: self)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try presenter?.load()
        } catch {
            assertionFailure(error.localizedDescription)
        }

        self.closeButton.isHidden = !(presenter?.shouldShowCloseButton ?? true)
    }

    var didOpenBooker = false
    func update(viewModel: DetailViewModel, rows: [(name: String, row: DetailRow)], silently: Bool) {
        if silently {
            self.viewModel = viewModel
            return
        }
        if !viewModel.header.isEqualTo(otherHeader: self.viewModel.header) {
            updateHeaderViewContent(viewModel: viewModel.header)
        }
        self.view.backgroundColor = viewModel.backgroundColor
        updateContent(viewModel: viewModel, rows: rows)
        updateBookingButton(with: viewModel.bottomButton, sdkManager: viewModel.sdkManager, id: viewModel.id)
        updateKinohodTicketBookerButton(viewModel: viewModel)
        self.viewModel = viewModel
        setupTableFooterView()
        if !didOpenBooker {
            openKinohodBookerModule()
        }
    }

    func setLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }

    func updateBookingButton() {
        updateBookingButton(
            with: viewModel.bottomButton,
            sdkManager: viewModel.sdkManager,
            id: viewModel.id
        )
    }

    var viewController: UIViewController? {
        return self
    }

    func displayEventAddedInCalendarCompletion() {
        hideBottomPanel()
    }

    override func setToTrack() {
        self.presenter?.sdkManager.detailDelegate?.set(scrollView: tableView)
    }

    override func shouldUseZeroStatusBarHeight() -> Bool {
        return self.presenter?.sdkManager.detailDelegate?.shouldUseZeroStatusBarHeight() ?? false
    }

    private func updateContent(
        viewModel: DetailViewModel,
        rows: [(name: String, row: DetailRow)]
    ) {
        let newRowViews = getUpdatedRowViews(viewModel: viewModel, rows: rows)

        setNewRowViews(newRowViews)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func updateHeaderViewContent(
        viewModel: DetailHeaderViewModelProtocol
    ) {
        if let viewModel = viewModel as? DetailHeaderViewModel {
            if headerView == nil {
                let headerView: DetailHeaderView = .fromNib()
                setupHeader(headerView: headerView, height: 250)
            }
            if let headerView = headerView as? DetailHeaderView {
                headerView.onAdd = { [weak self] in
                    self?.onAddToFavoriteButtonClick()
                }
                headerView.onClose = { [weak self] in
                    self?.dismiss()
                }
                headerView.set(viewModel: viewModel)
            }
        }

        if let viewModel = viewModel as? DetailMovieHeaderViewModel {
            let settingBlock: ((MovieVideoHeaderView) -> Void) = { [weak self] headerView in
                headerView.onClose = { [weak self] in
                    self?.dismiss()
                }
                headerView.isSkeletonShown = self?.isLoading ?? false
                headerView.set(viewModel: viewModel)
                headerView.openVideoController = { [weak self] controller in
                    guard let self = self else {
                        return
                    }
                    guard let controller = controller else {
                        return
                    }
                    self.presenter?.sdkManager.analyticsDelegate?.movieTrailerOpened(
                        movieID: self.presenter?.id ?? "",
                        genres: viewModel.genres
                    )
                    if self.presentedViewController == nil {
                        self.present(controller, animated: true) {
                            controller.player?.play()
                        }
                    } else {
                        self.presentedViewController?.present(controller, animated: true) {
                            controller.player?.play()
                        }
                    }
                }
            }

            if headerView == nil {
                let headerView: MovieVideoHeaderView = .fromNib()
                settingBlock(headerView)
                setupHeader(headerView: headerView, height: headerView.estimatedHeight)
            }
            if let headerView = headerView as? MovieVideoHeaderView {
                settingBlock(headerView)
            }
        }

        if let viewModel = viewModel as? DetailCinemaHeaderViewModel {
            let settingBlock: ((CinemaHeaderView) -> Void) = { headerView in
                headerView.isSkeletonShown = self.isLoading
                headerView.shouldShowCloseButton = self.presenter?.shouldShowCloseButton ?? true
                headerView.shouldUpdateTopConstraint = self.shouldUseZeroStatusBarHeight()
                headerView.onClose = { [weak self] in
                    self?.dismiss()
                }
                headerView.set(viewModel: viewModel)
                self.updateHeaderIfNeeded(height: headerView.estimatedHeight)
            }

            if headerView == nil {
                let headerView: CinemaHeaderView = .fromNib()
                settingBlock(headerView)
                setupHeader(headerView: headerView, height: headerView.estimatedHeight)
            }
            if let headerView = headerView as? CinemaHeaderView {
                settingBlock(headerView)
            }
        }
    }

    //Compares new row views to the old ones this way: first, delete the rows, that exist in old rowViews, but do not exist in the new rowViews. Second, add the rows, which do not exist in the old rowViews, but exist in the new rowViews. Then, update the changed views.
    private func setNewRowViews(_ newRowViews: [(name: String, view: UIView)]) {
        var deleted = [Int]()
        for (index, oldRowView) in rowViews.reversed().enumerated() {
            if !newRowViews.contains(where: { $0.name == oldRowView.name }) {
                deleted += [index]
                rowViews.remove(at: index)
            }
        }
        tableView.beginUpdates()
        tableView.deleteRows(at: deleted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        tableView.endUpdates()

        var added = [Int]()
        for (index, newRowView) in newRowViews.enumerated() {
            if !rowViews.contains(where: { $0.name == newRowView.name }) {
                added += [index]
                rowViews.insert(newRowView, at: index)
            }
        }
        tableView.beginUpdates()
        tableView.insertRows(at: added.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        tableView.endUpdates()

        var updated = [Int]()
        for index in 0 ..< newRowViews.count where rowViews[index].view != newRowViews[index].view {
            rowViews[index] = newRowViews[index]
            updated += [index]
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: updated.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        tableView.endUpdates()
    }

    private func getUpdatedRowViews(
        viewModel: DetailViewModel,
        rows: [(name: String, row: DetailRow)]
    ) -> [(name: String, view: UIView)] {
        var newRowViews: [(name: String, view: UIView)] = []

        for row in rows {
            let cachedView = rowViews.first(where: { $0.name == row.name })
            let areEqual = areViewModelRowsEqual(row: row, viewModel: viewModel, comparedTo: self.viewModel)
            if let view = cachedView, areEqual {
                newRowViews.append(view)
            } else {
                if let rowView = makeView(row: row, viewModel: viewModel) {
                    newRowViews.append((name: row.name, view: rowView))
                }
            }
        }
        return newRowViews
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func areViewModelRowsEqual(
        row: (name: String, row: DetailRow),
        viewModel: DetailViewModel,
        comparedTo anotherViewModel: DetailViewModel?
    ) -> Bool {
        guard let anotherViewModel = anotherViewModel else {
            return false
        }

        let detailRowViewModel = viewModel.rows.first(where: { $0.viewName == row.name })
        let anotherDetailRowViewModel = anotherViewModel.rows.first(where: { $0.viewName == row.name })

        switch row.row {
        case .info:
            guard let detailRowViewModel = detailRowViewModel as? DetailInfoViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailInfoViewModel else {
                    return false
            }
            return detailRowViewModel == anotherDetailRowViewModel /*&&
                detailRowViewModel.shouldExpandDescription == anotherDetailRowViewModel.shouldExpandDescription*/
        case .map:
            guard let detailRowViewModel = detailRowViewModel as? DetailMapViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailMapViewModel else {
                    return false
            }

            return detailRowViewModel == anotherDetailRowViewModel
        case .taxi:
            guard let detailRowViewModel = detailRowViewModel as? DetailTaxiViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailTaxiViewModel else {
                    return false
            }

            return detailRowViewModel == anotherDetailRowViewModel
        case .horizontalItems:
            guard let detailRowViewModel = detailRowViewModel as? DetailHorizontalItemsViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailHorizontalItemsViewModel else {
                    return false
            }

            return detailRowViewModel == anotherDetailRowViewModel
        case .verticalItems:
            guard let detailRowViewModel = detailRowViewModel as? DetailVerticalItemsViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailVerticalItemsViewModel else {
                    return false
            }

            return detailRowViewModel == anotherDetailRowViewModel
        case .tags:
            guard let detailRowViewModel = detailRowViewModel as? DetailTagsViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailTagsViewModel else {
                    return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .share:
            return true
        case .location:
            guard let detailRowViewModel = detailRowViewModel as? DetailLocationViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailLocationViewModel else {
                    return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .calendar:
            guard let detailRowViewModel = detailRowViewModel as? DetailCalendarViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailCalendarViewModel else {
                    return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .routePlaces:
            guard let detailRowViewModel = detailRowViewModel as? DetailRoutePlacesViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailRoutePlacesViewModel else {
                return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .routeMap:
            guard let detailRowViewModel = detailRowViewModel as? DetailRouteMapViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailRouteMapViewModel
            else {
                return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .schedule:
            guard let detailRowViewModel = detailRowViewModel as? DetailScheduleViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailScheduleViewModel
            else {
                return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .movieFriendsLikes:
            guard let detailRowViewModel = detailRowViewModel as? MovieFriendsLikesViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? MovieFriendsLikesViewModel
            else {
                return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .contactInfo:
            guard let detailRowViewModel = detailRowViewModel as? DetailContactInfoViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailContactInfoViewModel
            else {
                return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .youtubeVideo:
            guard let detailRowViewModel = detailRowViewModel as? VideosHorizontalListViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? VideosHorizontalListViewModel
            else {
                return false
            }
            return detailRowViewModel == anotherDetailRowViewModel

        case .cinemaAddress:
            guard let detailRowViewModel = detailRowViewModel as? CinemaAddressViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? CinemaAddressViewModel
            else {
                return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .extendedInfo:
            guard let detailRowViewModel = detailRowViewModel as? DetailExtendedInfoViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailExtendedInfoViewModel
            else {
                return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .onlineCinemaList:
            guard let detailRowViewModel = detailRowViewModel as? DetailOnlineCinemaListViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailOnlineCinemaListViewModel
            else {
                return false
            }
            return detailRowViewModel == anotherDetailRowViewModel
        case .horizontalCards:
            guard let detailRowViewModel = detailRowViewModel as? DetailHorizontalItemsViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailHorizontalItemsViewModel else {
                    return false
            }

            return detailRowViewModel == anotherDetailRowViewModel
        case .bookingInfo:
            guard let detailRowViewModel = detailRowViewModel as? DetailBookingInfoViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailBookingInfoViewModel else {
                    return false
            }

            return detailRowViewModel == anotherDetailRowViewModel
        case .bookingODPInfo:
            guard let detailRowViewModel = detailRowViewModel as? DetailBookingODPInfoViewModel,
                let anotherDetailRowViewModel = anotherDetailRowViewModel as? DetailBookingODPInfoViewModel else {
                    return false
            }

            return detailRowViewModel == anotherDetailRowViewModel
        case .eventCalendar:
            return false
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func makeView(
        row: (name: String, row: DetailRow),
        viewModel: DetailViewModel
    ) -> UIView? {
        guard let viewModel = viewModel.rows.first(where: { $0.viewName == row.name }) else {
            return nil
        }

        switch row.row {
        case .info:
            guard let viewModel = viewModel as? DetailInfoViewModel else {
                return nil
            }
            let typedView = row.row.makeView(from: viewModel) as? DetailInfoView
//            if viewModel.shouldExpandDescription {
//                typedView?.isOnlyExpanded = true
//            }
            typedView?.isSkeletonShown = self.isLoading
            typedView?.onExpand = { [weak self] in
                guard let self = self else {
                    return
                }
                let offsetBefore = self.tableView.contentOffset
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    self.tableView.contentOffset = offsetBefore
                    //TODO: Scroll to top here if needed
                }
            }
            return typedView
        case .map:
            guard let mapViewModel = viewModel as? DetailMapViewModel else {
                return nil
            }

            //TODO: currentView should conform from EmbeddedMapViewProtocol
            if let currentMapView = currentMapView as? DetailMapView {
                currentMapView.setup(viewModel: mapViewModel)
                currentMapView.set(delegate: self)
                return currentMapView
            } else {
                guard let currentMapView = row.row.makeView(from: mapViewModel)
                    as? DetailMapView else {
                        return nil
                }
                currentMapView.set(delegate: self)
                return currentMapView
            }
        case .taxi:
            guard let taxiViewModel = viewModel as? DetailTaxiViewModel else {
                return nil
            }

            let typedView = row.row.makeView(
                from: taxiViewModel
            ) as? DetailTaxiView

            typedView?.onTaxiButtonClick = {
//                self?.presenter?.taxiPressed()
            }

            return typedView
        case .horizontalItems:
            guard let horizontalItemsViewModel = viewModel as? DetailHorizontalItemsViewModel else {
                return nil
            }

            let typedView = row.row.makeView(
                from: horizontalItemsViewModel
            ) as? DetailHorizontalCollectionView

            typedView?.set(
                layout: DetailHorizontalListFlowLayout(
                    itemSizeType: horizontalItemsViewModel.itemSize
                )
            )

            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }

            typedView?.onCellClick = { [weak self] horizontalItemViewModel in
                if let position = horizontalItemViewModel.position {
                    self?.presenter?.horizontalItemPressed(list: row.name, position: position)
                }
            }
            return typedView
        case .verticalItems:
            guard let verticalItemsViewModel = viewModel as? DetailVerticalItemsViewModel else {
                return nil
            }

            let typedView = row.row.makeView(
                from: verticalItemsViewModel
            ) as? DetailSectionCollectionView<
                ListCollectionViewCell
            >

            typedView?.set(
                layout: SectionListFlowLayout(
                    itemSizeType: verticalItemsViewModel.itemSizeType
                )
            )

            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }

            typedView?.onCellClick = { [weak self] verticalItemViewModel in
                if let position = verticalItemViewModel.position {
                    self?.presenter?.verticalItemPressed(list: row.name, position: position)
                }
            }

            typedView?.onCellAddButtonTap = { [weak self] eventViewModel in
                self?.presenter?.addToFavorite(itemViewModel: eventViewModel)
            }

            return typedView
        case .tags:
            guard let tagsViewModel = viewModel as? DetailTagsViewModel else {
                return nil
            }
            let typedView = row.row.makeView(from: tagsViewModel) as? DetailTagsView
            return typedView
        case .share:
            guard let shareViewModel = viewModel as? DetailShareViewModel else {
                return nil
            }
            let typedView = row.row.makeView(from: shareViewModel) as? DetailShareView
            typedView?.onShare = { [weak self] in
                self?.presenter?.share()
            }
            return typedView
        case .location:
            guard let locationViewModel = viewModel as? DetailLocationViewModel else {
                return nil
            }
            if let view = detailLocationView {
                view.setup(viewModel: locationViewModel)
                view.onAddress = { [weak self] in
                    self?.showMap(with: locationViewModel.location.location)
                }
                view.onTaxi = { [weak self] in
                    self?.presenter?.callTaxi()
                }
                return view
            } else {
                let typedView = row.row.makeView(from: locationViewModel) as? DetailLocationView
                typedView?.onAddress = { [weak self] in
                    self?.showMap(with: locationViewModel.location.location)
                }
                typedView?.onTaxi = { [weak self] in
                    self?.presenter?.callTaxi()
                }
                detailLocationView = typedView
                return typedView
            }
        case .calendar:
            guard let calendarViewModel = viewModel as? DetailCalendarViewModel else {
                return nil
            }
            bottomPanel.setup(
                with: calendarViewModel.notificationText,
                addToCalendarText: calendarViewModel.addToCalendarText
            )
            let typedView = row.row.makeView(from: calendarViewModel) as? DetailCalendarView
            typedView?.onEventClick = { [weak self] event in
                guard let strongSelf = self else {
                    return
                }


                let canAddNotification = strongSelf.presenter?.canAddNotifcation(
                    viewModel: event
                ) ?? false
                strongSelf.bottomPanel.update(
                    date: event.mainDateString,
                    event: event.eventDescription,
                    canAddNotification: canAddNotification
                )

                strongSelf.bottomPanel.onAddToCalendarAction = {
                    strongSelf.presenter?.addToCalendar(viewModel: event)
                }

                strongSelf.bottomPanel.onAddNotificationAction = {
                    strongSelf.presenter?.addNotification(viewModel: event)
                }

                strongSelf.showBottomPanel()

                if !strongSelf.bottomPanel.isHidden {
                    strongSelf.showBottomPanel()
                }
            }
            typedView?.onLayoutUpdate = { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.tableView.beginUpdates()
                strongSelf.tableView.endUpdates()

                // workaround for iOS 9 & 10: status bar blinks after update
                if #available(iOS 11, *) { } else {
                    var contentOffset = strongSelf.tableView.contentOffset
                    contentOffset.y += 0.5
                    strongSelf.tableView.setContentOffset(
                        contentOffset,
                        animated: false
                    )
                }
            }
            return typedView
        case .routePlaces:
            guard let routePlacesViewModel = viewModel as? DetailRoutePlacesViewModel else {
                return nil
            }

            let typedView = row.row.makeView(from: routePlacesViewModel) as? DetailRouteView
            typedView?.onPlaceClick = { [weak self] index in
                self?.presenter?.routeItemPressed(list: row.name, position: index)
            }
            typedView?.onShareClick = { [weak self] index in
                self?.presenter?.shareItem(list: row.name, position: index)
            }
            typedView?.onAddToFavoritesClick = { [weak self] index in
                self?.presenter?.addItemToFavorites(list: row.name, position: index)
            }
            return typedView
        case .routeMap:
            guard let routeMapViewModel = viewModel as? DetailRouteMapViewModel else {
                return nil
            }

            let typedView = row.row.makeView(from: routeMapViewModel) as? DetailRouteMapView
            return typedView
        case .schedule:
            guard let scheduleViewModel = viewModel as? DetailScheduleViewModel else {
                return nil
            }

            let typedView = row.row.makeView(from: scheduleViewModel) as? DetailScheduleView
            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            return typedView
        case .contactInfo:
            guard let contactInfoViewModel = viewModel as? DetailContactInfoViewModel else {
                return nil
            }
            let typedView = row.row.makeView(from: contactInfoViewModel) as? DetailContactInfoView
            return typedView
        case .youtubeVideo:
            guard let videoViewModel = viewModel as? VideosHorizontalListViewModel,
                !videoViewModel.subviews.isEmpty
            else {
                return nil
            }
            let module = videoViewModel.makeModule()
            switch module {
            case .view(let view):
                return view
            case .viewController(let controller):
                self.addChild(controller)
                return controller.view
            case .none:
                return nil
            }
        case .movieFriendsLikes:
            guard let friendsLikesViewModel = viewModel as? MovieFriendsLikesViewModel else {
                return nil
            }
            let typedView = row.row.makeView(from: friendsLikesViewModel) as? MovieFriendsLikesView
            typedView?.isSkeletonShown = self.isLoading
            typedView?.sharingSource = self
            typedView?.apiService = self.presenter.flatMap { APIService(sdkManager: $0.sdkManager) }
            return typedView
        case .cinemaAddress:
            guard let viewModel = viewModel as? CinemaAddressViewModel else {
                return nil
            }
            let typedView = row.row.makeView(from: viewModel) as? CinemaAddressView
            typedView?.isSkeletonShown = isLoading
            typedView?.shouldShowInAppButton = !(presenter?.sdkManager.detailDelegate?.isOpenFromMap() ?? false)
            typedView?.presentBlock = { [weak self] alert in
                self?.present(alert, animated: true)
            }
            typedView?.onOpenInAppMap = { [weak self] in
                self?.presenter?.openMap()
            }
            typedView?.onSelectMapType = { [weak self] type in
                self?.presenter?.sendAnalytic(with: type)
            }
            return typedView
        case .extendedInfo:
            guard let viewModel = viewModel as? DetailExtendedInfoViewModel else {
                return nil
            }
            let typedView = row.row.makeView(from: viewModel) as? DetailExtendedInfoView

            return typedView
        case .onlineCinemaList:
            guard let viewModel = viewModel as? DetailOnlineCinemaListViewModel else {
                return nil
            }
            let typedView = row.row.makeView(from: viewModel) as? DetailOnlineCinemaListView
            typedView?.onLinkTap = { [weak self] model, link in
                self?.handleOpenOnlineCinemaList(model: model, link: link)
            }

            return typedView
        case .horizontalCards:
            guard let horizontalItemsViewModel = viewModel as? DetailHorizontalItemsViewModel else {
                return nil
            }

            let typedView = row.row.makeView(
                from: horizontalItemsViewModel
            ) as? DetailHorizontalCardsView
            return typedView
        case .bookingInfo:
            guard let bookingInfoViewModel = viewModel as? DetailBookingInfoViewModel else {
                return nil
            }

            let typedView = row.row.makeView(
                from: bookingInfoViewModel
            ) as? DetailBookingInfoView
            typedView?.apiService = self.presenter.flatMap { APIService(sdkManager: $0.sdkManager) }
            typedView?.update(with: bookingInfoViewModel)
            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            typedView?.onPresent = { [weak self] module in
                self?.present(module, animated: true, completion: nil)
            }
            return typedView
        case .bookingODPInfo:
            guard let viewModel = viewModel as? DetailBookingODPInfoViewModel else {
                return nil
            }

            let typedView = row.row.makeView(
                from: viewModel
            ) as? DetailBookingODPInfoView
            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            typedView?.setup(viewModel: viewModel)
            return typedView
        case .eventCalendar:
            return nil
        }
    }

    private func showBottomPanel() {
        bottomPanel.setNeedsLayout()
        bottomPanel.layoutIfNeeded()

        if bottomPanel.superview == nil {
            bottomPanel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomPanel)
            let bottomPanelTopConstraint: NSLayoutConstraint = {
                if #available(iOS 11.0, *) {
                    return bottomPanel.topAnchor.constraint(
                        equalTo: view.safeAreaLayoutGuide.bottomAnchor
                    )
                } else {
                    return bottomPanel.topAnchor.constraint(
                        equalTo: view.bottomAnchor
                    )
                }
            }()
            NSLayoutConstraint.activate(
                [
                    bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    bottomPanelTopConstraint
                ]
            )

            self.bottomPanelTopConstraint = bottomPanelTopConstraint

            view.insertSubview(bottomPanelDimView, belowSubview: bottomPanel)
            view.insertSubview(bottomPanelPadView, aboveSubview: bottomPanelDimView)
        }

        bottomPanelDimView.alpha = 0.0
        bottomPanelDimView.frame = view.bounds

        if #available(iOS 11.0, *) {
            bottomPanelPadView.frame = CGRect(
                x: 0,
                y: view.frame.maxY - view.safeAreaInsets.bottom - (bottomPanel.height / 2),
                width: view.frame.width,
                height: view.safeAreaInsets.bottom + (bottomPanel.height / 2)
            )
        }

        bottomPanel.isHidden = false
        bottomPanelDimView.isHidden = false
        bottomPanelPadView.isHidden = false

        view.setNeedsLayout()
        view.layoutIfNeeded()

        bottomPanelTopConstraint?.constant = -bottomPanel.height

        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.view.layoutIfNeeded()
                self.bottomPanelDimView.alpha = 1.0
            },
            completion: { _ in
                self.bottomPanel.layoutIfNeeded()
            }
        )
    }


    @objc
    private func hideBottomPanel() {
        view.setNeedsLayout()
        view.layoutIfNeeded()

        bottomPanelTopConstraint?.constant = 0
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.view.layoutIfNeeded()
                self.bottomPanelDimView.alpha = 0.0
            },
            completion: { _ in
                self.bottomPanelDimView.isHidden = true
                self.bottomPanelPadView.isHidden = true
                self.bottomPanel.isHidden = true
            }
        )
    }

    var isKinohodTicketBookerButtonShown = false
    private func updateKinohodTicketBookerButton(viewModel: DetailViewModel) {
        guard let theme = self.themeProvider?.current else {
            return
        }

        guard
//            !isKinohodTicketBookerButtonShown && viewModel.ticketPurchaseModule != nil &&
            viewModel.showTicketPurchaseButton
        else {
            return
        }

        let button = self.scheduleButton ?? UIButton(type: .system)
        button.backgroundColor = theme.palette.accent
        button.setTitleColor(UIColor.white, for: .normal)

        let title = NSLocalizedString("ScheduleAndTickets", bundle: .primeSdk, comment: "")
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.font(of: 16, weight: .semibold)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(openKinohodBooker), for: .touchUpInside)
        self.view.addSubview(button)
        self.scheduleButton = button

        var additionalInset: CGFloat = 0
        button.snp.remakeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(15)
            make.trailing.equalTo(view.snp.trailing).offset(-15)
            make.height.equalTo(45)
            if #available(iOS 11.0, *) {
                if view.safeAreaInsets.bottom > 0 {
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-11)
                    additionalInset = view.safeAreaInsets.bottom + 11
                } else {
                    make.bottom.equalTo(view.snp.bottom).offset(-15)
                    additionalInset = 15
                }
            } else {
                make.bottom.equalTo(view.snp.bottom).offset(-15)
                additionalInset = 15
            }
        }
        tableView.contentInset.bottom = 45 + additionalInset
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        isKinohodTicketBookerButtonShown = true
    }

    @objc
    func openKinohodBooker(sender: UIButton?) {
        openKinohodBookerModule()
    }

    var fpc: FloatingPanelController?

    private func openKinohodBookerModule() {
        guard
            let module = presenter?.getKinohodTicketsBooker(
                shouldConstrainHeight: false
            ) as? KinohodTicketsBookerViewController,
            viewModel.showTicketPurchaseButton
        else {
            return
        }

        fpc = FloatingPanelController()
        fpc?.delegate = self
        fpc?.set(contentViewController: module)
        fpc?.track(scrollView: module.tableView)
        fpc?.isRemovalInteractionEnabled = true
        fpc?.surfaceView.grabberTopPadding = 10
        if #available(iOS 11, *) {
            fpc?.surfaceView.cornerRadius = 12.0
        } else {
            fpc?.surfaceView.cornerRadius = 0.0
        }

        if let fpc = fpc {
            DispatchQueue.main.async {
                self.didOpenBooker = true
                self.present(fpc, animated: true, completion: nil)
            }
        }

        module.floatingPanelSource = self.fpc
//        module.modalPresentationStyle = .fullScreen
//        present(module, animated: true)
    }

    override func onAddToFavoriteButtonClick() {
        presenter?.addToFavorites()
    }

    override func onBottomButtonClick(_ sender: Any) {
        presenter?.open()
    }

    func setupTableFooterView() {
        guard
            viewModel.ticketPurchaseModule != nil && !viewModel.showTicketPurchaseButton,
            let module = presenter?.getKinohodTicketsBooker(
                shouldConstrainHeight: true
            ) as? KinohodTicketsBookerViewController,
            self.tableView.tableFooterView == nil
        else {
            return
        }

        module.onContentHeightChange = { [weak self] _ in
            if let height = self?.tableView.tableFooterView?.systemLayoutSizeFitting(
                UIView.layoutFittingCompressedSize
            ).height {
                self?.tableView.tableFooterView?.frame.size.height = height
                self?.tableView.tableFooterView = self?.tableView.tableFooterView
            }
        }

        module.remindCinemaClosure = { [weak self] in
            self?.presenter?.sendScheduleAnalytic()
            let alert = UIAlertController(
                title: "",
                message: NSLocalizedString("KinohodBookerAlertTitle", bundle: .primeSdk, comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("KinohodBookerAlertButton", bundle: .primeSdk, comment: ""),
                    style: .default,
                    handler: nil
                )
            )
            module.present(alert, animated: true, completion: nil)
        }

        self.addChild(module)
        self.tableView.tableFooterView = module.view
//        tableView.tableFooterView?.frame.size.height = height
//        self.view.layoutSubviews()
    }

    private func handleOpenOnlineCinemaList(model: TypeGroupedPricesViewModel, link: String) {
        if model.isPurhase {
            self.presenter?.sdkManager.analyticsDelegate?.iviBuyPressed()
        }

        if model.isRent {
            self.presenter?.sdkManager.analyticsDelegate?.iviRentPressed()
        }

        if let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension DetailModuleViewController: FloatingPanelControllerDelegate {
    // swiftlint:disable identifier_name
    func floatingPanel(
        _ vc: FloatingPanelController,
        layoutFor newCollection: UITraitCollection
    ) -> FloatingPanelLayout? {
        let beautyInsetConst: CGFloat = 15.0
        var bottomInset: CGFloat = 216.0
        if let infoViewIndex = rowViews.firstIndex(where: { $0.view is DetailInfoView }) {
            let infoViewRect = rowViews[infoViewIndex].view.bounds
            let rectInSuperview = view.convert(infoViewRect, from: rowViews[infoViewIndex].view)
            let topInset = rectInSuperview.minY
            bottomInset = UIScreen.main.bounds.size.height - topInset - beautyInsetConst

            if #available(iOS 11.0, *) {
                bottomInset -= view.safeAreaInsets.bottom
            }
        }

        return KinohodTicketsBookerPanelLayout(initialBottomInset: bottomInset)
    }
    // swiftlint:enable identifier_name
}

extension DetailModuleViewController: ThemeUpdatable {
    func update(with theme: Theme) {
    }
}
// swiftlint:enable file_length
