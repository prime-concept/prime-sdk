import Foundation
import PromiseKit

protocol KinohodTicketsBookerPresenterProtocol: AnyObject {
    func refresh()
    func searchCinemas(query: String?)
    func loadNextPage()
    func selectCalendarItem(index: Int)
    func getTicketPurchaseModule(schedule: KinohodTicketsBookerScheduleViewModel.Schedule) -> UIViewController

    func didSelectMovie(movie: MovieNowViewModel)
    func didSelectCinema(cinema: CinemaCardViewModel)
    func didSelectSchedule(schedule: KinohodTicketsBookerScheduleViewModel.Schedule)

    func prepareLoadingViewModel() -> KinohodTicketsBookerViewModel?
    func openMap()

    var shouldConstrainHeight: Bool { get }
    var currentModule: KinohodTicketsBookerModuleSource { get }
}

final class KinohodTicketsBookerPresenter: KinohodTicketsBookerPresenterProtocol {
    weak var view: KinohodTicketsBookerViewProtocol?
    var shouldConstrainHeight: Bool = false

    private var viewName: String
    private var configuration: Configuration
    private var sdkManager: PrimeSDKManagerProtocol
    private var apiService: APIServiceProtocol
    private var moduleSource: KinohodTicketsBookerModuleSource
    private var configView: KinohodTicketsBookerConfigView
    private var viewModel: KinohodTicketsBookerViewModel
    private var searchViewModel: KinohodTicketsBookerViewModel
    private var locationService: LocationServiceProtocol

    private var shouldLoadNextPageForDate: [String: Bool] = [:]
    private var shouldLoadNextPageSearchForDate: [String: Bool] = [:]
    private let limit = 25

    private var currentCancelToken: (() -> Void)?
    private var isCurrentlyLoadingForDate: [String: Bool] = [:]
    private var isCurrentlyLoadingSearchForDate: [String: Bool] = [:]
    private var isSearchActive = false
    private var searchQuery: String?

    var currentModule: KinohodTicketsBookerModuleSource {
        return self.moduleSource
    }

    init?(
        view: KinohodTicketsBookerViewProtocol,
        viewName: String,
        moduleSource: KinohodTicketsBookerModuleSource,
        shouldConstrainHeight: Bool,
        configuration: Configuration,
        apiService: APIServiceProtocol,
        locationService: LocationServiceProtocol,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        guard
            let configView = configuration.views[viewName] as? KinohodTicketsBookerConfigView,
            let viewModel = KinohodTicketsBookerViewModel(
                name: viewName,
                moduleSource: moduleSource,
                configView: configView,
                sdkManager: sdkManager,
                configuration: configuration
            ),
            let searchViewModel = KinohodTicketsBookerViewModel(
                name: viewName,
                moduleSource: moduleSource,
                configView: configView,
                sdkManager: sdkManager,
                configuration: configuration
            )
        else {
            return nil
        }

        self.view = view
        self.viewName = viewName
        self.configuration = configuration
        self.apiService = apiService
        self.locationService = locationService
        self.sdkManager = sdkManager
        self.moduleSource = moduleSource
        self.shouldConstrainHeight = shouldConstrainHeight
        self.configView = configView
        self.viewModel = viewModel
        self.searchViewModel = searchViewModel
    }

    func refresh() {
        self.loadCalendar()
    }

    func searchCinemas(query: String?) {
        if let indexToSet = self.viewModel.calendar?.selectedIndex,
            searchQuery == nil || searchQuery == "" {
            searchViewModel.calendar?.selectedIndex = indexToSet
        }
        self.isSearchActive = query != nil
        self.searchQuery = query

        guard query != nil else {
            let dateString = self.viewModel.calendar?.selectedDay.dateString
                ?? (DataStorage.shared.getValue(for: "today") as? String ?? "")
            self.view?.setLoading(isCalendarLoading: false, isSchedulesLoading: false)
            let state: KinohodTicketsBookerState = self.viewModel.schedulesForDate[dateString]?.sections
                .isEmpty ?? true
                    ? .empty
                    : .normal

            self.view?.set(state: state)

            self.view?.update(viewModel: self.viewModel)
            return
        }

        let query = query ?? ""

        guard
            let loadAction = configuration.actions[configView.actions.search] as? LoadConfigAction,
            let dateString = self.searchViewModel.calendar?.selectedDay.dateString
        else {
            return
        }

        self.currentCancelToken?()
        self.searchViewModel.schedulesForDate[dateString] = nil
        self.sdkManager.analyticsDelegate?.movieSearchCinemaTapped(
            text: query,
            movieID: self.moduleSource.movieID ?? ""
        )

        print("BOOKER: start searching cinemas")

        DataStorage.shared.set(value: self.limit, for: "limit", in: loadAction.name)
        DataStorage.shared.set(value: query, for: "cinema_name", in: loadAction.name)
        DataStorage.shared.set(value: dateString, for: "date", in: loadAction.name)

        loadAction.request.inject(action: loadAction.name, viewModel: self.viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: self.viewModel)

        let request = self.apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: self.sdkManager.apiDelegate
        )

        request.promise.done { [weak self] deserializedViewMap in
            guard let self = self else {
                return
            }

            print("BOOKER: finished searching cinemas for \(query)")

            self.shouldLoadNextPageSearchForDate[dateString] = !deserializedViewMap.valueForAttributeID.isEmpty
            self.searchViewModel.loadSchedules(
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                configView: self.configView,
                otherConfigViews: self.configuration.views,
                adBannerDelegate: self,
                dateString: dateString
            )

            if dateString == self.searchViewModel.calendar?.selectedDay.dateString {
                self.view?.setLoading(isCalendarLoading: false, isSchedulesLoading: false)
                let state: KinohodTicketsBookerState = self.searchViewModel.schedulesForDate[dateString]?.sections
                    .isEmpty ?? true
                        ? .empty
                        : .normal

                self.view?.set(state: state)

                self.view?.update(viewModel: self.searchViewModel)
            } else {
                print("BOOKER: not displaying \(dateString)")
            }
        }.catch { _ in
            print("BOOKER: error loading for \(dateString)")
        }

        self.currentCancelToken = request.cancel
    }

    func loadNextPage() {
        let shouldLoadNextPageForDateLocal = self.isSearchActive
            ? self.shouldLoadNextPageSearchForDate
            : self.shouldLoadNextPageForDate

        guard
            let calendar = self.isSearchActive ? self.searchViewModel.calendar : self.viewModel.calendar,
            shouldLoadNextPageForDateLocal[calendar.selectedDay.dateString] == true,
            self.configView.attributes.supportPagination
        else {
            return
        }
        print("BOOKER: loading next page for selected index date \(calendar.days[calendar.selectedIndex].dateString)")
        self.loadScheduleForDate(dateString: calendar.days[calendar.selectedIndex].dateString)
    }

    func selectCalendarItem(index: Int) {
        let viewModel = self.isSearchActive ? self.searchViewModel : self.viewModel

        guard
            let calendar = viewModel.calendar,
            index < calendar.days.count,
            index != calendar.selectedIndex,
            let schedule = viewModel.schedulesForDate[calendar.days[index].dateString]
        else {
            return
        }

        sdkManager.analyticsDelegate?.scheduleDateChanged(
            oldTime: calendar.days[calendar.selectedIndex].date,
            newTime: calendar.days[index].date
        )

        self.view?.setLoading(isCalendarLoading: false, isSchedulesLoading: false)
        self.view?.clearCacheAds()

        calendar.selectedIndex = index
        viewModel.calendar = calendar

        print("BOOKER: did select calendar date \(calendar.days[index].dateString), updating viewModel")
        self.view?.update(viewModel: viewModel)

        if self.isSearchActive {
            guard
                let calendar = self.viewModel.calendar,
                index < calendar.days.count,
                index != calendar.selectedIndex
            else {
                return
            }

            calendar.selectedIndex = index
            viewModel.calendar = calendar

            self.searchCinemas(query: self.searchQuery)
            return
        }

        if schedule.isDummy {
            self.view?.setLoading(isCalendarLoading: false, isSchedulesLoading: true)
            self.view?.set(state: .loading)
            if self.isCurrentlyLoadingForDate[calendar.days[index].dateString] == false {
                print("BOOKER: select, start load for \(calendar.days[index].dateString)")
                self.loadScheduleForDate(
                    dateString: calendar.days[index].dateString,
                    completion: {
                        self.loadSchedulesForNext()
                    }
                )
            }
        } else {
            print("BOOKER: select, no load needed for \(calendar.days[index].dateString)")
            self.view?.set(
                state: schedule.sections.isEmpty ? .empty : .normal
            )
            self.loadSchedulesForNext()
        }
    }

    func getTicketPurchaseModule(schedule: KinohodTicketsBookerScheduleViewModel.Schedule) -> UIViewController {
        return TicketPurchaseWebAssembly(schedule: schedule, sdkManager: self.sdkManager).make()
    }

    func didSelectCinema(cinema: CinemaCardViewModel) {
        let configView = self.configuration.views[cinema.viewName]

        guard
            let cellConfigView = configView as? CinemaCardConfigView,
            let openActionName = cellConfigView.actions.tap,
            let openAction = self.configuration.actions[openActionName] as? OpenModuleConfigAction
        else {
            return
        }

        self.view?.open(model: cinema, action: openAction, config: configuration, sdkManager: sdkManager)
    }

    func didSelectMovie(movie: MovieNowViewModel) {
        let configView = configuration.views[movie.viewName]

        guard
            let cellConfigView = configView as? MovieNowConfigView,
            let openActionName = cellConfigView.actions.tap,
            let openAction = self.configuration.actions[openActionName] as? OpenModuleConfigAction
        else {
            return
        }

        self.view?.open(model: movie, action: openAction, config: configuration, sdkManager: sdkManager)
    }

    func didSelectSchedule(schedule: KinohodTicketsBookerScheduleViewModel.Schedule) {
        self.sdkManager.analyticsDelegate?.seanceOpened(
            cinemaID: schedule.cinemaID,
            movieID: schedule.movieID,
            movieFormat: schedule.group.name,
            scheduleTime: schedule.startTime,
            price: schedule.minPrice
        )
    }

    func prepareLoadingViewModel() -> KinohodTicketsBookerViewModel? {
        if self.viewModel.calendar == nil {
            self.viewModel.calendar = getDummyCalendarViewModel()
        }

        return self.viewModel
    }

    func openMap() {
        self.sdkManager.mapDelegate?.openMap(with: nil)
    }

    private func loadCalendar() {
        guard
            let loadAction = self.configuration.actions[configView.actions.loadCalendar] as? LoadConfigAction
        else {
            return
        }

        print("BOOKER: start loading calendar")
        self.view?.setLoading(isCalendarLoading: true, isSchedulesLoading: true)
        self.view?.set(state: .loading)

        loadAction.request.inject(action: loadAction.name, viewModel: self.viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: self.viewModel)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done { [weak self] deserializedViewMap in
            guard let self = self else {
                return
            }

            print("BOOKER: calendar load finished")

            self.viewModel.reloadCalendar(valueForAttributeID: deserializedViewMap.valueForAttributeID)
            self.searchViewModel.reloadCalendar(valueForAttributeID: deserializedViewMap.valueForAttributeID)
            self.view?.update(viewModel: self.viewModel)

            if let calendar = self.viewModel.calendar {
                for day in calendar.days {
                    self.isCurrentlyLoadingForDate[day.dateString] = false
                    self.shouldLoadNextPageForDate[day.dateString] = true
                }
                self.loadScheduleForDate(
                    dateString: calendar.days[calendar.selectedIndex].dateString,
                    completion: {
                        self.loadSchedulesForNext()
                    }
                )
            } else {
                self.view?.set(state: .emptyCalendar)
                self.view?.setLoading(isCalendarLoading: false, isSchedulesLoading: false)
            }
        }.cauterize()
    }

    private func loadScheduleForDate(dateString: String, completion: (() -> Void)? = nil) {
        self.locationService.getLocation().done { [weak self] coordinate in
            self?.loadScheduleForDate(
                dateString: dateString,
                coordinate: coordinate,
                completion: completion
            )
        }.catch { [weak self] _ in
            self?.loadScheduleForDate(
                dateString: dateString,
                coordinate: nil,
                completion: completion
            )
        }
    }

    private func loadScheduleForDate(
        dateString: String,
        coordinate: GeoCoordinate?,
        completion: (() -> Void)? = nil
    ) {
        guard
            let loadAction = self.configuration.actions[configView.actions.load] as? LoadConfigAction
        else {
            return
        }

        var isCurrentlyLoadingForDateLocal = self.isSearchActive
            ? self.isCurrentlyLoadingSearchForDate
            : self.isCurrentlyLoadingForDate

        var shouldLoadNextPageForDateLocal = self.isSearchActive
            ? self.shouldLoadNextPageSearchForDate
            : self.shouldLoadNextPageForDate

        let viewModel = self.isSearchActive
            ? self.searchViewModel
            : self.viewModel

        isCurrentlyLoadingForDateLocal[dateString] = true
        print("BOOKER: started loading for \(dateString)")

        let request = self.makeSchedulesRequest(
            loadAction: loadAction,
            dateString: dateString,
            coordinate: coordinate
        )

        request.done { [weak self] deserializedViewMap in
            guard let self = self else {
                return
            }

            completion?()

            print("BOOKER: finished loading for \(dateString)")

            isCurrentlyLoadingForDateLocal[dateString] = false

            shouldLoadNextPageForDateLocal[dateString] = !deserializedViewMap.valueForAttributeID.isEmpty
            viewModel.loadSchedules(
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                configView: self.configView,
                otherConfigViews: self.configuration.views,
                adBannerDelegate: self,
                dateString: dateString
            )

            //if it is currently displayed - change state
            if dateString == viewModel.calendar?.selectedDay.dateString {
                self.view?.setLoading(isCalendarLoading: false, isSchedulesLoading: false)
                let state: KinohodTicketsBookerState = viewModel.schedulesForDate[dateString]?.sections
                    .isEmpty ?? true
                        ? .empty
                        : .normal

                self.view?.set(state: state)

                self.view?.update(viewModel: viewModel)
            } else {
                print("BOOKER: not displaying \(dateString)")
            }
        }.catch { _ in
            shouldLoadNextPageForDateLocal[dateString] = false
            print("BOOKER: error loading for \(dateString)")
        }.finally {
            if self.isSearchActive {
                self.shouldLoadNextPageSearchForDate = shouldLoadNextPageForDateLocal
                self.isCurrentlyLoadingSearchForDate = isCurrentlyLoadingForDateLocal
            } else {
                self.shouldLoadNextPageForDate = shouldLoadNextPageForDateLocal
                self.isCurrentlyLoadingForDate = isCurrentlyLoadingForDateLocal
            }
        }
    }

    private func makeSchedulesRequest(
        loadAction: LoadConfigAction,
        dateString: String,
        coordinate: GeoCoordinate?
    ) -> Promise<DeserializedViewMap> {
        let viewModel = self.isSearchActive
            ? self.searchViewModel
            : self.viewModel

        print("BOOKER: making schedules request for \(dateString)")

        let offset = viewModel.schedulesForDate[dateString]?.scheduleBlocksCount ?? 0

        DataStorage.shared.set(value: limit, for: "limit", in: loadAction.name)
        DataStorage.shared.set(value: offset, for: "offset", in: loadAction.name)
        DataStorage.shared.set(value: dateString, for: "date", in: loadAction.name)
        DataStorage.shared.set(value: coordinate?.latitude ?? "", for: "latitude", in: loadAction.name)
        DataStorage.shared.set(value: coordinate?.longitude ?? "", for: "longitude", in: loadAction.name)

        loadAction.request.inject(action: loadAction.name, viewModel: viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: viewModel)

        let request = apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        )

        self.currentCancelToken = request.cancel

        return request.promise
    }

    private func loadSchedulesForNext() {
        let viewModel = self.isSearchActive
            ? self.searchViewModel
            : self.viewModel
        let isCurrentlyLoadingForDateLocal = self.isSearchActive
            ? self.isCurrentlyLoadingSearchForDate
            : self.isCurrentlyLoadingForDate


        guard let calendar = viewModel.calendar else {
            return
        }

        var dates: [String] = []

        if let dateString = calendar.days[safe: calendar.selectedIndex + 1]?.dateString {
            dates.append(dateString)
        }

        // TODO: - Fix race condition bug with request parameters
//        if let dateString = calendar.days[safe: calendar.selectedIndex + 2]?.dateString {
//            dates.append(dateString)
//        }

        dates.forEach { dateString in
            if viewModel.schedulesForDate[dateString]?.isDummy == true &&
                isCurrentlyLoadingForDateLocal[dateString] == false {
                print("BOOKER: start load for next date \(dateString)")
                self.loadScheduleForDate(dateString: dateString)
            }
        }
    }

    private func getDummyCalendarViewModel() -> KinohodTicketsBookerCalendarViewModel {
        let calendarViewModel = KinohodTicketsBookerCalendarViewModel()
        calendarViewModel.days = [
            KinohodTicketsBookerCalendarViewModel.DayItem.dummyViewModel,
            KinohodTicketsBookerCalendarViewModel.DayItem.dummyViewModel,
            KinohodTicketsBookerCalendarViewModel.DayItem.dummyViewModel,
            KinohodTicketsBookerCalendarViewModel.DayItem.dummyViewModel,
            KinohodTicketsBookerCalendarViewModel.DayItem.dummyViewModel,
            KinohodTicketsBookerCalendarViewModel.DayItem.dummyViewModel,
            KinohodTicketsBookerCalendarViewModel.DayItem.dummyViewModel,
            KinohodTicketsBookerCalendarViewModel.DayItem.dummyViewModel
        ]
        calendarViewModel.selectedIndex = 0
        calendarViewModel.isDummy = true

        return calendarViewModel
    }
}

// MARK: - AdBannerDelegate

extension KinohodTicketsBookerPresenter: AdBannerDelegate {
    func heightShouldChange() {
        self.view?.updateHeights()
    }
}
