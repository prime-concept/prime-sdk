import DeckTransition
import FloatingPanel
import Foundation
import UIKit

enum KinohodTicketsBookerState {
    case normal, empty, loading, emptyCalendar
}

protocol KinohodTicketsBookerViewProtocol: AnyObject {
    func update(viewModel: KinohodTicketsBookerViewModel)
    func open(
        model: ViewModelProtocol,
        action: OpenModuleConfigAction,
        config: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    )
    func set(state: KinohodTicketsBookerState)
    func updateHeights()
    func setLoading(isCalendarLoading: Bool, isSchedulesLoading: Bool)
    func clearCacheAds()
}

//swiftlint:disable file_length
final class KinohodTicketsBookerViewController: UIViewController, KinohodTicketsBookerViewProtocol {
    var presenter: KinohodTicketsBookerPresenterProtocol?

    let openModuleRoutingService = OpenModuleRoutingService()

    private static let dayItemSize = CGSize(width: 43, height: 73)
    private static let dayItemSpacing: CGFloat = 1
    private static let daysInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var daysCollectionView: UICollectionView!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var emptyViewLabel: UILabel!
    @IBOutlet private weak var firstDateButton: UIButton!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var calendarTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var emptyCalendarView: UIView!
    @IBOutlet private weak var emptyCalendarLabel: UILabel!
    @IBOutlet private weak var openMapButton: UIButton!
    @IBOutlet var remindCinemaButton: UIButton!

    @IBOutlet private var collectionViewToSafeAreaConstraint: NSLayoutConstraint!
    @IBOutlet private var collectionViewToSearchBarConstraint: NSLayoutConstraint!

    private var previousTableViewHeight = CGFloat(0)
    private var state: KinohodTicketsBookerState = .empty {
        didSet {
            switch state {
            case .normal, .loading:
                self.emptyView.isHidden = true
                self.tableView.isHidden = false
                self.emptyCalendarView.isHidden = true
            case .empty:
                self.emptyView.isHidden = false
                self.tableView.isHidden = true
                self.emptyCalendarView.isHidden = true
            case .emptyCalendar:
                self.emptyView.isHidden = true
                self.tableView.isHidden = true
                self.emptyCalendarView.isHidden = false
                self.openMapButton.isHidden = true

                guard let moduleSource = self.presenter?.currentModule else {
                    return
                }

                switch moduleSource {
                case .movie:
                    self.emptyCalendarLabel.text = NSLocalizedString(
                        "KinohodBookerEmptyCalendarMovie",
                        bundle: .primeSdk,
                        comment: ""
                    )
                case .cinema:
                    self.emptyCalendarLabel.text = NSLocalizedString(
                        "KinohodBookerEmptyCalendarCinema",
                        bundle: .primeSdk,
                        comment: ""
                    )
                }
            }
        }
    }

    private var viewModel: KinohodTicketsBookerViewModel?

    private var isCalendarLoading: Bool = false
    private var isSchedulesLoading: Bool = false

    var onLayoutUpdate: (() -> Void)?

    var cachedAds: [Int: UIViewController] = [:]

    var onContentHeightChange: ((CGFloat) -> Void)?
    var remindCinemaClosure: (() -> Void)?
    weak var floatingPanelSource: FloatingPanelController?

    var themeProvider: ThemeProvider?

    convenience init() {
        self.init(nibName: "KinohodTicketsBookerViewController", bundle: .primeSdk)
    }

    deinit {
        self.tableView?.removeObserver(self, forKeyPath: "contentSize")
    }

    @IBAction func onFirstDateButtonClick(_ sender: Any) {
        guard
            let viewModel = viewModel,
            let calendarViewModel = viewModel.calendar
        else {
            return
        }
        let cellX = KinohodTicketsBookerViewController.daysInsets.left
            + CGFloat(calendarViewModel.firstDateIndex) * KinohodTicketsBookerViewController.dayItemSize.width
            + KinohodTicketsBookerViewController.dayItemSpacing * CGFloat(calendarViewModel.firstDateIndex)
        let normalizedCellX = min(
            cellX,
            daysCollectionView.contentSize.width - self.view.bounds.width
        )

        if normalizedCellX > self.view.bounds.width {
            self.daysCollectionView.setContentOffset(
                CGPoint(x: normalizedCellX, y: 0.0),
                animated: true
            )
        }
        self.selectItem(index: calendarViewModel.firstDateIndex)
    }

    @IBAction func remindCinemaButtonClick(_ sender: Any) {
        remindCinemaClosure?()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupFonts()
        self.presenter?.refresh()
        self.setupEmptyView()
        self.setupTableView()
        self.setupCollectionView()
        self.setupSearchBar()
        self.setupOpenMapButton()
        self.setupRemindCinemaButton()

        self.contentHeight.isActive = presenter?.shouldConstrainHeight ?? false

        if self.presenter?.shouldConstrainHeight == true {
            self.calendarTopConstraint.constant = 7
        } else {
            if case .movie = self.presenter?.currentModule {
                self.calendarTopConstraint.constant = 14
            } else {
                self.calendarTopConstraint.constant = 34
            }
        }

        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

        self.themeProvider = ThemeProvider(themeUpdatable: self)
    }

    private func setupFonts() {
        self.emptyViewLabel.font = UIFont.font(of: 15)
        self.emptyCalendarLabel.font = UIFont.font(of: 16)
    }

    private func setupTableView() {
        tableView.isScrollEnabled = !(presenter?.shouldConstrainHeight ?? false)
        tableView.showsVerticalScrollIndicator = false

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(cellClass: CinemaTableViewCell.self)
        tableView.register(cellClass: AdBannerTableViewCell.self)
        tableView.register(cellClass: MovieScheduleTableViewCell.self)
        tableView.register(cellClass: MovieNowTableViewCell.self)
    }

    private func setupEmptyView() {
        emptyView.isHidden = true
        emptyViewLabel.text = viewModel?.noDataText
    }

    private func setupRemindCinemaButton() {
        let title = NSLocalizedString("KinohodBookerRemindCinema", bundle: .primeSdk, comment: "").uppercased()
        remindCinemaButton.setTitle(title, for: .normal)
    }

    private func setupCollectionView() {
        daysCollectionView.register(cellClass: ScheduleCalendarItemDayCell.self)
        heightConstraint.constant = KinohodTicketsBookerViewController.dayItemSize.height
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = KinohodTicketsBookerViewController.dayItemSize
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = KinohodTicketsBookerViewController.dayItemSpacing
        layout.sectionInset = KinohodTicketsBookerViewController.daysInsets
        daysCollectionView.setCollectionViewLayout(layout, animated: true)
        daysCollectionView.showsHorizontalScrollIndicator = false

        daysCollectionView.dataSource = self
        daysCollectionView.delegate = self

        switch self.presenter?.currentModule {
        case .cinema:
            self.collectionViewToSafeAreaConstraint.isActive = true
            self.collectionViewToSearchBarConstraint.isActive = false
            self.openMapButton.isHidden = true
        case .movie:
            self.collectionViewToSafeAreaConstraint.isActive = false
            self.collectionViewToSearchBarConstraint.isActive = true
            self.openMapButton.isHidden = false
        default:
            break
        }
    }

    private func setupSearchBar() {
        self.searchBar.delegate = self
    }

    private func setupOpenMapButton() {
        let image = UIImage(named: "show_all_cinemas_icon", in: .primeSdk, compatibleWith: nil)?
            .withRenderingMode(.alwaysTemplate)
        self.openMapButton.setImage(image, for: .normal)
    }

    private func selectItem(index: Int) {
        presenter?.selectCalendarItem(index: index)
    }

    func setLoading(isCalendarLoading: Bool, isSchedulesLoading: Bool) {
        self.isCalendarLoading = isCalendarLoading
        self.isSchedulesLoading = isSchedulesLoading
        let isLoading = isCalendarLoading || isSchedulesLoading
        if isLoading {
            if isCalendarLoading {
                if let viewModel = presenter?.prepareLoadingViewModel() {
                    update(viewModel: viewModel)
                }
            } else {
                if let viewModel = self.viewModel {
                    update(viewModel: viewModel)
                }
            }
        }
    }

    func update(viewModel: KinohodTicketsBookerViewModel) {
        self.viewModel = viewModel
        daysCollectionView.reloadData()
        tableView.reloadData()

        firstDateButton.setTitle(viewModel.calendar?.nearestDateString ?? "", for: .normal)

        if viewModel.currentSchedules?.sections.isEmpty ?? true && !(viewModel.currentSchedules?.isDummy ?? false) {
            setupEmptyState()
            cachedAds = [:]
        }
    }

    func updateHeights() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    func set(state: KinohodTicketsBookerState) {
        self.state = state
    }

    private func setupEmptyState() {
        if
            let dayCount = viewModel?.calendar?.days.count,
            dayCount > 1 &&
            viewModel?.calendar?.days[1].hasData ?? false &&
            viewModel?.calendar?.selectedIndex == 0
        {
            firstDateButton.setTitle(
                NSLocalizedString("KinohodBookerFirstDateTomorrowButtonTitle", bundle: .primeSdk, comment: ""),
                for: .normal
            )

            emptyViewLabel.text = NSLocalizedString(
                "KinohodBookerNoSeancesTodayEmptyStateText",
                bundle: .primeSdk,
                comment: ""
            )
        } else {
            let localizedFirstDate = NSLocalizedString(
                "KinohodBookerFirstDateOtherDateButtonTitle",
                bundle: .primeSdk,
                comment: ""
            )
            firstDateButton.setTitle(
                "\(localizedFirstDate) \(viewModel?.calendar?.nearestDateString ?? "")",
                for: .normal
            )

            let localizedEmptyView = NSLocalizedString(
                "KinohodBookerNoSeancesThisDayEmptyStateText",
                bundle: .primeSdk,
                comment: ""
            )
            emptyViewLabel.text = "\(localizedEmptyView) \(viewModel?.calendar?.nearestDateString ?? "") 😉"
        }
    }

    private func loadBooking(schedule: KinohodTicketsBookerScheduleViewModel.Schedule) {
        if let destination = presenter?.getTicketPurchaseModule(schedule: schedule) {
            let transitionDelegate = DeckTransitioningDelegate()
            if #available(iOS 13.0, *) {
                destination.modalPresentationStyle = .pageSheet
            } else {
                destination.transitioningDelegate = transitionDelegate
                destination.modalPresentationStyle = .custom
            }
            self.present(destination, animated: true, completion: nil)
        }
    }

    @IBAction private func openMapTapped(_ sender: UIButton) {
        self.presenter?.openMap()
    }

    //swiftlint:disable all
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if
            let obj = object as? UITableView,
            obj == self.tableView && keyPath == "contentSize",
            let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize,
            presenter?.shouldConstrainHeight ?? false
        {
            let newHeight = max(newSize.height, 350)
            contentHeight.constant = newHeight
            onContentHeightChange?(newHeight)
        }
    }
    //swiftlint:enable all

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

    func clearCacheAds() {
        cachedAds = [:]
    }
}

extension KinohodTicketsBookerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard
            let schedules = viewModel?.currentSchedules
        else {
            return 0
        }
        return schedules.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let schedules = viewModel?.currentSchedules,
            section < schedules.sections.count
        else {
            emptyView.isHidden = false
            return 0
        }

        switch schedules.sections[section] {
        case .adBanner, .cinema, .movie:
            return 1
        case .schedule(rows: let rows):
            return rows.count
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let schedules = viewModel?.currentSchedules
        else {
            return UITableViewCell()
        }

        switch schedules.sections[indexPath.section] {
        case .adBanner(adBanner: let bannerViewModel):
            let cell: AdBannerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            if let cachedAd = cachedAds[indexPath.section] {
                cell.update(withModule: cachedAd)
            } else {
                cell.update(withViewModel: bannerViewModel)
                if let child = cell.module {
                    self.addChild(child)
                    cachedAds[indexPath.section] = child
                }
            }
            return cell
        case .schedule(rows: let scheduleRows):
            let cell: MovieScheduleTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.update(
                with: scheduleRows[indexPath.row],
                isSkeletonShown: isSchedulesLoading,
                onSelect: { [weak self] schedule in
                    self?.presenter?.didSelectSchedule(schedule: schedule)
                    self?.loadBooking(schedule: schedule)
                }
            )
            return cell
        case .cinema(cinemaCard: let cardViewModel):
            let cell: CinemaTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.update(with: cardViewModel)
            cell.isSkeletonShown = isSchedulesLoading
            cell.selectionStyle = .none
            return cell
        case .movie(movieCard: let movieNowViewModel):
            let cell: MovieNowTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.update(with: movieNowViewModel)
            cell.isSkeletonShown = isSchedulesLoading
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let schedules = viewModel?.currentSchedules
        else {
            if #available(iOS 11, *) {
                return CGFloat.leastNonzeroMagnitude
            }
            return 1.1
        }

        switch schedules.sections[indexPath.section] {
        case .adBanner(adBanner: let bannerViewModel):
            return CGFloat(bannerViewModel.height)
        case .schedule(rows: _):
            return UITableView.automaticDimension
        case .cinema(cinemaCard: _):
            return 86
        case .movie(movieCard: _):
            return 165
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let schedules = viewModel?.currentSchedules
        else {
            if #available(iOS 11, *) {
                return CGFloat.leastNonzeroMagnitude
            }
            return 1.1
        }

        switch schedules.sections[indexPath.section] {
        case .adBanner(adBanner: let bannerViewModel):
            return CGFloat(bannerViewModel.height)
        case .schedule(rows: _):
            return UITableView.automaticDimension
        case .cinema(cinemaCard: let cinema):
            if cinema.hasBadge {
                return 106
            } else {
                return 86
            }
        case .movie(movieCard: _):
            return 165
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard
            let schedules = viewModel?.currentSchedules
        else {
            return false
        }

        switch schedules.sections[indexPath.section] {
        case .cinema, .movie:
            return true
        default:
            return false
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard
            let schedules = viewModel?.currentSchedules
        else {
            return
        }
        switch schedules.sections[indexPath.section] {
        case .cinema(cinemaCard: let cinemaCard):
            presenter?.didSelectCinema(cinema: cinemaCard)
            return
        case .movie(movieCard: let movieCard):
            presenter?.didSelectMovie(movie: movieCard)
            return
        default:
            return
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if #available(iOS 11, *) {
            return .leastNonzeroMagnitude
        }
        return 1.1
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let schedules = viewModel?.currentSchedules {
            if schedules.scheduleBlocksCount == section - 1 &&
            viewModel?.calendar?.selectedDay.hasData == true && !schedules.isDummy {
                presenter?.loadNextPage()
            }
        }
        return nil
    }
}

extension KinohodTicketsBookerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let viewModel = viewModel?.calendar else {
            return 0
        }
        return viewModel.days.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let viewModel = viewModel?.calendar else {
            return UICollectionViewCell()
        }

        let cell: ScheduleCalendarItemDayCell = collectionView.dequeueReusableCell(
            for: indexPath
        )

        guard let dayItem = viewModel.days[safe: indexPath.row] else {
            fatalError("View model has invalid data")
        }

        cell.update(with: dayItem)
//        cell.dayItemView.topText = dayItem.dayOfWeek
//        cell.dayItemView.mainText = dayItem.dayNumber
//        cell.dayItemView.bottomText = dayItem.month
//
//        cell.dayItemView.state = dayItem.hasData ? .withEvents : .withoutEvents
        if indexPath.row == viewModel.selectedIndex {
            cell.tileView.state = .selected
        }

        cell.tileView.isSkeletonShown = isCalendarLoading

        cell.tileView.onClick = { [weak self] in
            self?.selectItem(index: indexPath.row)
        }
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension KinohodTicketsBookerViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.floatingPanelSource?.move(to: .full, animated: true)
        self.searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.floatingPanelSource?.move(to: .half, animated: true)
        self.searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.presenter?.searchCinemas(query: nil)
        } else {
            self.presenter?.searchCinemas(query: searchText)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.floatingPanelSource?.move(to: .half, animated: true)
        self.presenter?.searchCinemas(query: nil)
    }
}

// MARK: - ThemeUpdatable

extension KinohodTicketsBookerViewController: ThemeUpdatable {
    func update(with theme: Theme) {
        self.openMapButton.tintColor = theme.palette.accent
    }
}
