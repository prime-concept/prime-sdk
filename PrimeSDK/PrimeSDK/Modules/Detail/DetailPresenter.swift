import EventKit
import Foundation
import PromiseKit
import SwiftyJSON

//swiftlint:disable file_length
protocol DetailPresenterProtocol {
    var sdkManager: PrimeSDKManagerProtocol { get }
    var id: String { get }
    var shouldShowCloseButton: Bool { get }

    func load() throws
    func horizontalItemPressed(list: String, position: Int)
    func verticalItemPressed(list: String, position: Int)
    func addToFavorites()
    func addToFavorite(itemViewModel: ListItemViewModel)

    func addToCalendar(viewModel: DetailCalendarViewModel.EventItem)
    func canAddNotifcation(viewModel: DetailCalendarViewModel.EventItem) -> Bool
    func addNotification(viewModel: DetailCalendarViewModel.EventItem)

    func open()
    func share()
    func callTaxi()

    func routeItemPressed(list: String, position: Int)
    func shareItem(list: String, position: Int)
    func addItemToFavorites(list: String, position: Int)

    func getKinohodTicketsBooker(shouldConstrainHeight: Bool) -> UIViewController?

    func openMap()
    func sendScheduleAnalytic()
    func sendAnalytic(with type: String)
}

protocol DetailViewProtocol: AnyObject, SFViewControllerPresentable {
    func update(viewModel: DetailViewModel, rows: [(name: String, row: DetailRow)], silently: Bool)
    func setLoading(_ isLoading: Bool)
    func updateBookingButton()
    var viewController: UIViewController? { get }

    func displayEventAddedInCalendarCompletion()
}

protocol СinemaNameProviderProtocol: AnyObject {
    func update() -> String
}

final class DetailPresenter: DetailPresenterProtocol, СinemaNameProviderProtocol {
    weak var view: DetailViewProtocol?

    var apiService: APIService
    let googleMapsService: GoogleMapsService
    let locationService: LocationServiceProtocol
    let openModuleRoutingService: OpenModuleRoutingService
    let sharingService: SharingServiceProtocol
    let eventsLocalNotificationsService: EventsLocalNotificationsServiceProtocol
    let sdkManager: PrimeSDKManagerProtocol

    private var configuration: Configuration
    private var detailName: String
    private var subviews: [String] = []
    var id: String
    private var rows: [(name: String, row: DetailRow)] = []
    private var viewModel = DetailViewModel.empty


    private var itemLocation: (address: String, coords: CLLocation?)?

    private var needsToLoadFromCache: Bool = true

    var shouldShowCloseButton: Bool {
        return sdkManager.detailDelegate?.shouldShowCloseButton() ?? true
    }

    init(
        view: DetailViewProtocol,
        detailName: String,
        id: String,
        configuration: Configuration,
        apiService: APIService,
        googleMapsService: GoogleMapsService,
        locationService: LocationServiceProtocol,
        openModuleRoutingService: OpenModuleRoutingService,
        sharingService: SharingServiceProtocol,
        eventsLocalNotificationsService: EventsLocalNotificationsServiceProtocol,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.configuration = configuration
        self.apiService = apiService
        self.googleMapsService = googleMapsService
        self.view = view
        self.detailName = detailName
        self.id = id
        self.locationService = locationService
        self.openModuleRoutingService = openModuleRoutingService
        self.sharingService = sharingService
        self.eventsLocalNotificationsService = eventsLocalNotificationsService
        self.sdkManager = sdkManager

        googleMapsService.register()
        self.registerForNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleChangedFavorites(notification:)),
            name: .itemFavoriteChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateBookingButton),
            name: Notification.Name("onProfileChange"),
            object: nil
        )
    }

    func load() throws {
        view?.setLoading(true)
        if let detailContainerView = configuration.views[detailName] as? DetailContainerConfigView {
            subviews = detailContainerView.subviews
            for subview in detailContainerView.subviews {
                if let view = configuration.views[subview] {
                    switch view.type {
                    case "detail-info", "detail-event-info":
                        rows += [(name: view.name, row: DetailRow.info)]
                    case "detail-map":
                        rows += [(name: view.name, row: DetailRow.map)]
                    case "detail-taxi":
                        rows += [(name: view.name, row: DetailRow.taxi)]
                    case "detail-horizontal-list":
                        rows += [(name: view.name, row: DetailRow.horizontalItems)]
                    case "detail-vertical-list":
                        rows += [(name: view.name, row: DetailRow.verticalItems)]
                    case "detail-tags":
                        rows += [(name: view.name, row: DetailRow.tags)]
                    case "detail-share":
                        rows += [(name: view.name, row: DetailRow.share)]
                    case "detail-location":
                        rows += [(name: view.name, row: DetailRow.location)]
                    case "detail-calendar":
                        rows += [(name: view.name, row: DetailRow.calendar)]
                    case "detail-route-places":
                        rows += [(name: view.name, row: DetailRow.routePlaces)]
                    case "detail-route-map":
                        rows += [(name: view.name, row: DetailRow.routeMap)]
                    case "detail-schedule":
                        rows += [(name: view.name, row: DetailRow.schedule)]
                    case "detail-contact-info":
                        rows += [(name: view.name, row: DetailRow.contactInfo)]
                    case "videos-horizontal-list":
                        rows += [(name: view.name, row: DetailRow.youtubeVideo)]
                    case "movie-friends-likes":
                        rows += [(name: view.name, row: DetailRow.movieFriendsLikes)]
                    case "detail-cinema-address":
                        rows += [(name: view.name, row: DetailRow.cinemaAddress)]
                    case "detail-info-extended":
                        rows += [(name: view.name, row: DetailRow.extendedInfo)]
                    case "detail-online-cinema-list":
                        rows += [(name: view.name, row: DetailRow.onlineCinemaList)]
                    case "detail-horizontal-cards":
                        rows += [(name: view.name, row: DetailRow.horizontalCards)]
                    case "detail-booking-info":
                        rows += [(name: view.name, row: DetailRow.bookingInfo)]
                    case "detail-booking-odp-info":
                        rows += [(name: view.name, row: DetailRow.bookingODPInfo)]
                    default:
                        break
                    }
                }
            }
        }
        view?.update(viewModel: getLoadingDetailViewModel() ?? .empty, rows: self.rows, silently: false)
        loadContainerWithLocation()
    }

    @objc
    private func updateBookingButton() {
        view?.updateBookingButton()
    }

    func loadContainerWithLocation() {
        guard let detailContainerView = configuration.views[detailName] as? DetailContainerConfigView else {
            return
        }

        if detailContainerView.attributes.allowsLocation {
            locationService.getLocation().done { [weak self] coordinate in
                self?.loadContainer(coordinate: coordinate, detailContainerView: detailContainerView)
            }.catch { [weak self] _ in
                self?.loadContainer(coordinate: nil, detailContainerView: detailContainerView)
            }
        } else {
            self.loadContainer(coordinate: nil, detailContainerView: detailContainerView)
        }
    }

    private func displayData(
        deserializedViewMap: DeserializedViewMap,
        coordinate: GeoCoordinate?,
        detailContainerView: DetailContainerConfigView,
        loadSupplementaryViews: Bool = true
    ) {
        guard let viewModel = DetailViewModel(
            name: detailContainerView.name,
            valueForAttributeID: deserializedViewMap.valueForAttributeID,
            configView: detailContainerView,
            otherConfigViews: self.configuration.views,
            sdkManager: sdkManager,
            configuration: configuration,
            getDistanceBlock: { coordinate in
                self.locationService.distance(to: coordinate)
            }
        ) else {
            return
        }
        view?.setLoading(false)
        self.viewModel = viewModel

        self.view?.update(viewModel: self.viewModel, rows: self.rows, silently: false)

        if loadSupplementaryViews {
            for row in self.rows.filter({ $0.row == .horizontalItems }) {
                self.loadHorizontalRowWithLocation(name: row.name, coordinate: coordinate)
            }

            for row in self.rows.filter({ $0.row == .verticalItems }) {
                self.loadVerticalRowWithLocation(name: row.name, coordinate: coordinate)
            }

            for row in self.rows.filter({ $0.row == .location }) {
                self.loadTaxi(name: row.name, coordinate: coordinate)
            }

            for row in self.rows.filter({ $0.row == .calendar }) {
                self.loadCalendar(name: row.name)
            }

            for row in self.rows.filter({ $0.row == .routeMap }) {
                self.loadRoutePolyline(name: row.name)
            }
        }
    }

    private func loadContainer(coordinate: GeoCoordinate?, detailContainerView: DetailContainerConfigView) {
        guard
            let actionName = detailContainerView.actions.load,
            let loadAction = configuration.actions[actionName] as? LoadConfigAction else {
                return
        }

        DataStorage.shared.set(value: id, for: "id", in: actionName)
        DataStorage.shared.set(value: coordinate?.latitude ?? "", for: "lat", in: actionName)
        DataStorage.shared.set(value: coordinate?.longitude ?? "", for: "lon", in: actionName)

        loadAction.request.inject(action: loadAction.name, viewModel: nil)


        if
            let cachedResponse = sdkManager.apiDelegate?.getCachedResponse(configRequest: loadAction.request)
        {
            loadAction.response.deserializer?.deserialize(
                json: cachedResponse
            ).done { [weak self] deserializedViewMap in
                if self?.needsToLoadFromCache == true {
                    self?.displayData(
                        deserializedViewMap: deserializedViewMap,
                        coordinate: coordinate,
                        detailContainerView: detailContainerView,
                        loadSupplementaryViews: false
                    )
                }
            }.cauterize()
        }

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { [weak self] deserializedViewMap in
            guard let strongSelf = self else {
                return
            }
            strongSelf.needsToLoadFromCache = false
            strongSelf.displayData(
                deserializedViewMap: deserializedViewMap,
                coordinate: coordinate,
                detailContainerView: detailContainerView,
                loadSupplementaryViews: true
            )
        }.cauterize()
    }

    func horizontalItemPressed(list: String, position: Int) {
        guard let viewModel = viewModel.rowForName[list] as? DetailHorizontalItemsViewModel else {
            return
        }

        guard let itemConfigView = configuration.views[viewModel.items[position].viewName]
            as? ListItemConfigView else {
                return
        }

        let selectedViewModel: ViewModelProtocol = viewModel.items[position]

        if
            let openActionName = itemConfigView.actions.tap,
            let openAction = configuration.actions[openActionName] as? OpenModuleConfigAction,
            let source = view?.viewController
        {
            openModuleRoutingService.route(
                using: selectedViewModel,
                openAction: openAction,
                from: source,
                configuration: configuration,
                sdkManager: sdkManager
            )
        }
    }

    func verticalItemPressed(list: String, position: Int) {
        guard let viewModel = viewModel.rowForName[list] as? DetailVerticalItemsViewModel else {
            return
        }

        guard let itemConfigView = configuration.views[viewModel.items[position].viewName] as? ListItemConfigView else {
            return
        }

        let selectedViewModel: ViewModelProtocol = viewModel.items[position]

        if
            let openActionName = itemConfigView.actions.tap,
            let openAction = configuration.actions[openActionName] as? OpenModuleConfigAction,
            let source = view?.viewController
        {
            openModuleRoutingService.route(
                using: selectedViewModel,
                openAction: openAction,
                from: source,
                configuration: configuration,
                sdkManager: sdkManager
            )
        }
    }

    func shareItem(list: String, position: Int) {
        guard let viewModel = viewModel.rowForName[list] as? DetailRoutePlacesViewModel else {
            return
        }

        guard let itemConfigView = configuration.views[
            viewModel.places[position].viewName
        ] as? ListItemConfigView else {
            return
        }

        let selectedViewModel: ViewModelProtocol = viewModel.places[position]

        if
            let shareActionName = itemConfigView.actions.share,
            let shareAction = configuration.actions[shareActionName] as? ShareConfigAction,
            let source = view?.viewController
        {
            sharingService.share(
                action: shareAction,
                viewModel: selectedViewModel,
                viewController: source
            )
        }
    }

    func routeItemPressed(list: String, position: Int) {
        guard let viewModel = viewModel.rowForName[list] as? DetailRoutePlacesViewModel else {
            return
        }

        guard let itemConfigView = configuration.views[
            viewModel.places[position].viewName
        ] as? ListItemConfigView else {
            return
        }

        let selectedViewModel: ViewModelProtocol = viewModel.places[position]

        if
            let openActionName = itemConfigView.actions.tap,
            let openAction = configuration.actions[openActionName] as? OpenModuleConfigAction,
            let source = view?.viewController
        {
            openModuleRoutingService.route(
                using: selectedViewModel,
                openAction: openAction,
                from: source,
                configuration: configuration,
                sdkManager: sdkManager
            )
        }
    }

    func addItemToFavorites(list: String, position: Int) {
        guard let viewModel = viewModel.rowForName[list] as? DetailRoutePlacesViewModel else {
            return
        }

        guard let itemConfigView = configuration.views[
            viewModel.places[position].viewName
            ] as? ListItemConfigView else {
                return
        }

        let selectedViewModel = viewModel.places[position]

        guard
            let actionName = itemConfigView.actions.toggleFavorite,
            let loadAction = configuration.actions[actionName] as? LoadConfigAction
        else {
            return
        }
        DataStorage.shared.set(
            value: selectedViewModel.isFavorite ? "delete" : "post",
            for: "method_type",
            in: actionName
        )
        let targetState = !selectedViewModel.isFavorite
        DataStorage.shared.set(value: targetState, for: "target_state", in: actionName)

        loadAction.request.inject(action: loadAction.name, viewModel: viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: viewModel)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            NotificationCenter.default.post(
                name: .itemFavoriteChanged,
                object: nil,
                userInfo: [
                    Favorites.notificationItemIDKey: strongSelf.viewModel.id,
                    Favorites.notificationItemIsFavoriteNowKey: targetState,
                    Favorites.notificationItemEntityTypeKey: strongSelf.viewModel.entityType
                ]
            )
        }.cauterize()
    }

    @objc
    private func handleChangedFavorites(notification: Notification) {
        guard
            let entityType = notification.userInfo?[Favorites.notificationItemEntityTypeKey] as? String,
            let id = notification.userInfo?[Favorites.notificationItemIDKey] as? String,
            let isFavorite = notification.userInfo?[Favorites.notificationItemIsFavoriteNowKey] as? Bool
            else {
                return
        }

        let favoriteItem = FavoriteItem(id: id, entityType: entityType, isFavoriteNow: isFavorite)

        if viewModel.id == favoriteItem.id && viewModel.isFavorite != favoriteItem.isFavoriteNow {
            viewModel.isFavorite = favoriteItem.isFavoriteNow
            view?.update(viewModel: viewModel, rows: rows, silently: false)
        }

        NotificationCenter.default.post(
            name: .detailItemFavoriteChanged,
            object: nil,
            userInfo: [
                Favorites.notificationItemIDKey: favoriteItem.id,
                Favorites.notificationItemIsFavoriteNowKey: favoriteItem.isFavoriteNow,
                Favorites.notificationItemEntityTypeKey: favoriteItem.entityType
            ]
        )

        for row in self.rows.filter({ $0.row == .horizontalItems }) {
            guard
                var rowViewModel = viewModel.rowForName[row.name] as? DetailHorizontalItemsViewModel
            else {
                continue
            }

            if let itemIndex = rowViewModel.items.firstIndex(
                where: { item in
                    item.id == favoriteItem.id && item.entityType == favoriteItem.entityType
                }
            ) {
                rowViewModel.items[itemIndex].isFavorite = isFavorite
                viewModel.rowForName[row.name] = rowViewModel
                view?.update(viewModel: viewModel, rows: rows, silently: true)
            }
        }

        for row in self.rows.filter({ $0.row == .verticalItems }) {
            guard
                var rowViewModel = viewModel.rowForName[row.name] as? DetailVerticalItemsViewModel
            else {
                continue
            }

            if let itemIndex = rowViewModel.items.firstIndex(
                where: { item in
                    item.id == favoriteItem.id && item.entityType == favoriteItem.entityType
                }
            ) {
                rowViewModel.items[itemIndex].isFavorite = isFavorite
                viewModel.rowForName[row.name] = rowViewModel
                view?.update(viewModel: viewModel, rows: rows, silently: true)
            }
        }
    }

    func addToFavorites() {
        guard let detailConfigView = configuration.views[detailName] as? DetailContainerConfigView else {
            return
        }

        guard
            let actionName = detailConfigView.actions.toggleFavorite,
            let loadAction = configuration.actions[actionName] as? LoadConfigAction
        else {
            return
        }

        DataStorage.shared.set(
            value: viewModel.isFavorite ? "delete" : "post",
            for: "method_type",
            in: actionName
        )
        let targetState = !viewModel.isFavorite
        DataStorage.shared.set(value: targetState, for: "target_state", in: actionName)

        loadAction.request.inject(action: loadAction.name, viewModel: viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: viewModel)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            NotificationCenter.default.post(
                name: .itemFavoriteChanged,
                object: nil,
                userInfo: [
                    Favorites.notificationItemIDKey: strongSelf.viewModel.id,
                    Favorites.notificationItemIsFavoriteNowKey: targetState,
                    Favorites.notificationItemEntityTypeKey: strongSelf.viewModel.entityType
                ]
            )
        }.cauterize()
    }

    func open() {
        if let url = self.viewModel.bottomButton?.url {
            if url.scheme != "http" || url.scheme != "https" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.view?.open(url: url)
            }
        }
    }

    func share() {
        guard let detailConfigView = configuration.views[detailName] as? DetailContainerConfigView else {
            return
        }

        guard
            let actionName = detailConfigView.actions.share,
            let shareAction = configuration.actions[actionName] as? ShareConfigAction else {
                return
        }

        sharingService.share(action: shareAction, viewModel: viewModel, viewController: view?.viewController)
    }

    func callTaxi() {
        for row in self.rows.filter({ $0.row == .location }) {
            guard let detailLocationViewModel = viewModel.rowForName[row.name] else {
                return
            }

            if let url = URL(string: detailLocationViewModel.attributes["url"] as? String ?? "") {
                view?.open(url: url)
            }
        }
    }

    private func loadTaxi(name: String, coordinate: GeoCoordinate?) {
        guard let detailLocationConfigView = configuration.views[name] as? DetailLocationConfigView else {
            return
        }

        let detailLocationViewModel = viewModel.rowForName[detailLocationConfigView.name]

        guard let lon = detailLocationViewModel?.attributes["lon"] as? Double,
              let lat = detailLocationViewModel?.attributes["lat"] as? Double,
              let address = detailLocationViewModel?.attributes["address"] as? String
        else {
            return
        }

        self.itemLocation = (address: address, coords: CLLocation(latitude: lat, longitude: lon))

        let actionName = detailLocationConfigView.actions.load
        guard let loadAction = configuration.actions[actionName] as? LoadConfigAction else {
            return
        }

        guard let coords = coordinate else {
            return
        }

        DataStorage.shared.set(value: coords.longitude, for: "start_lng", in: actionName)
        DataStorage.shared.set(value: coords.latitude, for: "start_lat", in: actionName)
        DataStorage.shared.set(value: lon, for: "end_lng", in: actionName)
        DataStorage.shared.set(value: lat, for: "end_lat", in: actionName)

        loadAction.request.inject(action: loadAction.name, viewModel: nil)
        loadAction.response.inject(action: loadAction.name, viewModel: nil)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { [weak self] deserializedViewMap in
            guard let strongSelf = self else {
                return
            }
            deserializedViewMap.valueForAttributeID.merge(
                detailLocationViewModel?.attributes ?? [:]
            ) { current, _ in current
            }

            guard let detailLocationViewModel = try? DetailLocationViewModel(
                viewName: name,
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                defaultAttributes: detailLocationConfigView.attributes
            ) else {
                return
            }

            strongSelf.viewModel.update(block: detailLocationViewModel, rowName: name)

            strongSelf.view?.update(viewModel: strongSelf.viewModel, rows: strongSelf.rows, silently: false)
        }.cauterize()
    }

    private func loadHorizontalRowWithLocation(name: String, coordinate: GeoCoordinate?) {
        guard let detailHorizontalListView = configuration.views[name] as? DetailHorizontalListConfigView else {
            return
        }

        if detailHorizontalListView.attributes.allowsLocation && coordinate == nil {
            locationService.getLocation().done { [weak self] coordinate in
                self?.loadHorizontalRow(
                    name: name,
                    coordinate: coordinate,
                    detailHorizontalListView: detailHorizontalListView
                )
            }.catch { [weak self] _ in
                self?.loadHorizontalRow(
                    name: name,
                    coordinate: coordinate,
                    detailHorizontalListView: detailHorizontalListView
                )
            }
        } else {
            self.loadHorizontalRow(
                name: name,
                coordinate: coordinate,
                detailHorizontalListView: detailHorizontalListView
            )
        }
    }

    private func loadRoutePolyline(name: String) {
        guard let detailRouteMapConfigView = configuration.views[name] as? DetailRouteMapConfigView else {
            return
        }

        let detailRouteMapViewModel = viewModel.rowForName[detailRouteMapConfigView.name]

        guard let origin = detailRouteMapViewModel?.attributes["origin"] as? String,
            let destination = detailRouteMapViewModel?.attributes["destination"] as? String,
            let waypoints = detailRouteMapViewModel?.attributes["waypoints"] as? String
        else {
            return
        }

        let actionName = detailRouteMapConfigView.actions.load
        guard let loadAction = configuration.actions[actionName] as? LoadConfigAction else {
            return
        }

        DataStorage.shared.set(value: origin, for: "origin", in: actionName)
        DataStorage.shared.set(value: destination, for: "destination", in: actionName)
        DataStorage.shared.set(value: waypoints, for: "waypoints", in: actionName)

        loadAction.request.inject(action: loadAction.name, viewModel: nil)
        loadAction.response.inject(action: loadAction.name, viewModel: nil)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { [weak self] deserializedViewMap in
            guard let strongSelf = self else {
                return
            }
            deserializedViewMap.valueForAttributeID.merge(
                detailRouteMapViewModel?.attributes ?? [:]
            ) { current, _ in current
            }

            guard let detailRouteMapViewModel = try? DetailRouteMapViewModel(
                viewName: name,
                valueForAttributeID: deserializedViewMap.valueForAttributeID
            ) else {
                return
            }

            strongSelf.viewModel.update(block: detailRouteMapViewModel, rowName: name)

            strongSelf.view?.update(viewModel: strongSelf.viewModel, rows: strongSelf.rows, silently: false)
        }.cauterize()
    }

    private func loadHorizontalRow(
        name: String,
        coordinate: GeoCoordinate?,
        detailHorizontalListView: DetailHorizontalListConfigView
    ) {
        guard let itemView = configuration.views[detailHorizontalListView.item] as? ListItemConfigView else {
            return
        }

        let actionName = detailHorizontalListView.actions.load
        guard let loadAction = configuration.actions[actionName] as? LoadConfigAction else {
            return
        }

        DataStorage.shared.set(value: id, for: "id", in: actionName)

        loadAction.request.inject(action: loadAction.name, viewModel: nil)
        loadAction.response.inject(action: loadAction.name, viewModel: nil)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { [weak self] deserializedViewMap in
            guard let strongSelf = self else {
                return
            }

            guard let horizontalItemsViewModel = try? DetailHorizontalItemsViewModel(
                viewName: detailHorizontalListView.name,
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                listConfigView: detailHorizontalListView,
                itemView: itemView,
                getDistanceBlock: { [weak self] coordinate in
                    self?.locationService.distance(to: coordinate)
                },
                sdkManager: strongSelf.sdkManager,
                configuration: strongSelf.configuration
            ) else {
                return
            }

            strongSelf.viewModel.update(block: horizontalItemsViewModel, rowName: detailHorizontalListView.name)

            strongSelf.view?.update(viewModel: strongSelf.viewModel, rows: strongSelf.rows, silently: false)
        }.cauterize()
    }

    private func loadVerticalRowWithLocation(name: String, coordinate: GeoCoordinate?) {
        guard let detailVerticalListView = configuration.views[name] as? DetailVerticalListConfigView else {
            return
        }

        if detailVerticalListView.attributes.allowsLocation && coordinate == nil {
            locationService.getLocation().done { [weak self] coordinate in
                self?.loadVerticalRow(
                    name: name,
                    coordinate: coordinate,
                    detailVerticalListView: detailVerticalListView
                )
            }.catch { [weak self] _ in
                self?.loadVerticalRow(
                    name: name,
                    coordinate: coordinate,
                    detailVerticalListView: detailVerticalListView
                )
            }
        } else {
            self.loadVerticalRow(name: name, coordinate: coordinate, detailVerticalListView: detailVerticalListView)
        }
    }

    private func loadVerticalRow(
        name: String,
        coordinate: GeoCoordinate?,
        detailVerticalListView: DetailVerticalListConfigView
    ) {
        guard let itemView = configuration.views[detailVerticalListView.item] as? ListItemConfigView else {
            return
        }

        let actionName = detailVerticalListView.actions.load
        guard let loadAction = configuration.actions[actionName] as? LoadConfigAction else {
            return
        }

        DataStorage.shared.set(value: id, for: "id", in: actionName)

        loadAction.request.inject(action: loadAction.name, viewModel: nil)
        loadAction.response.inject(action: loadAction.name, viewModel: nil)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { [weak self] deserializedViewMap in
            guard let strongSelf = self else {
                return
            }

            guard let verticalItemsViewModel = try? DetailVerticalItemsViewModel(
                viewName: detailVerticalListView.name,
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                listConfigView: detailVerticalListView,
                itemView: itemView,
                getDistanceBlock: { [weak self] coordinate in
                    self?.locationService.distance(to: coordinate)
                },
                sdkManager: strongSelf.sdkManager,
                configuration: strongSelf.configuration
            ) else {
                    return
            }

            strongSelf.viewModel.update(
                block: verticalItemsViewModel,
                rowName: detailVerticalListView.name
            )
            strongSelf.view?.update(viewModel: strongSelf.viewModel, rows: strongSelf.rows, silently: false)
        }.cauterize()
    }

    func addToFavorite(itemViewModel: ListItemViewModel) {
        guard
            let cellConfigView = configuration.views[itemViewModel.viewName] as? ListItemConfigView,
            let actionName = cellConfigView.actions.toggleFavorite,
            let loadAction = configuration.actions[actionName] as? LoadConfigAction else
        {
            return
        }

        var targetState: Bool = true
        for row in self.rows.filter({ $0.row == .verticalItems }) {
            guard
                let rowViewModel = viewModel.rowForName[row.name] as? DetailVerticalItemsViewModel
            else {
                continue
            }

            if let item = rowViewModel.items.first(
                where: { item in
                    item.id == itemViewModel.id && item.entityType == itemViewModel.entityType
                }
            ) {
               targetState = !item.isFavorite
            }
        }

        DataStorage.shared.set(value: targetState, for: "target_state", in: actionName)
        DataStorage.shared.set(
            value: targetState ? "post" : "delete",
            for: "method_type",
            in: actionName
        )

        loadAction.request.inject(action: loadAction.name, viewModel: itemViewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: itemViewModel)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { _ in
            NotificationCenter.default.post(
                name: .itemFavoriteChanged,
                object: nil,
                userInfo: [
                    Favorites.notificationItemIDKey: itemViewModel.id,
                    Favorites.notificationItemIsFavoriteNowKey: targetState,
                    Favorites.notificationItemEntityTypeKey: itemViewModel.entityType
                ]
            )
        }.cauterize()
    }

    func loadCalendar(name: String) {
        guard
            let detailCalendarConfigView = configuration.views[name] as? DetailCalendarConfigView
        else {
            return
        }

        let actionName = detailCalendarConfigView.actions.load
        guard let loadAction = configuration.actions[actionName] as? LoadConfigAction else {
            return
        }

        DataStorage.shared.set(value: id, for: "id", in: actionName)

        loadAction.request.inject(action: loadAction.name, viewModel: nil)
        loadAction.response.inject(action: loadAction.name, viewModel: nil)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { [weak self] deserializedViewMap in
            guard let strongSelf = self else {
                return
            }

            guard let calendarViewModel = try? DetailCalendarViewModel(
                viewName: detailCalendarConfigView.name,
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                defaultAttributes: detailCalendarConfigView.attributes
            ) else {
                return
            }

            strongSelf.viewModel.update(
                block: calendarViewModel,
                rowName: detailCalendarConfigView.name
            )
            strongSelf.view?.update(viewModel: strongSelf.viewModel, rows: strongSelf.rows, silently: false)
        }.cauterize()
    }

    func addToCalendar(viewModel: DetailCalendarViewModel.EventItem) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(
            to: .event,
            completion: { [weak self] granted, error in
                if granted && error == nil {
                    let event = EKEvent(eventStore: eventStore)

                    if let location = self?.itemLocation?.coords {
                        let structuredLocation = EKStructuredLocation(title: self?.itemLocation?.address ?? "")
                        structuredLocation.geoLocation = location
                        event.structuredLocation = structuredLocation
                    }

                    event.title = viewModel.title
                    event.startDate = viewModel.startDate
                    event.endDate = viewModel.endDate
                    event.calendar = eventStore.defaultCalendarForNewEvents

                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch {
                        return
                    }

                    DispatchQueue.main.async {
                        self?.view?.displayEventAddedInCalendarCompletion()
                    }
                }
            }
        )
    }

    func update() -> String {
        guard let shortTitle = viewModel.attributes["title"] as? String else {
            return ""
        }
        return shortTitle
    }

    func canAddNotifcation(viewModel: DetailCalendarViewModel.EventItem) -> Bool {
        return eventsLocalNotificationsService.canScheduleNotification(
            eventID: id,
            date: viewModel.startDate
        )
    }

    func addNotification(viewModel: DetailCalendarViewModel.EventItem) {
        eventsLocalNotificationsService.scheduleNotification(
            eventID: id,
            date: viewModel.startDate
        )

        view?.displayEventAddedInCalendarCompletion()
    }

    var bookerModule: UIViewController?

    func getKinohodTicketsBooker(shouldConstrainHeight: Bool) -> UIViewController? {
        if bookerModule != nil {
            return bookerModule
        }

        guard
            let detailConfigView = configuration.views[detailName] as? DetailContainerConfigView,
            let kinohodBookerViewName = detailConfigView.attributes.ticketPurchaseModule,
            let kinohodBookerModuleSource = detailConfigView.attributes.ticketPurchaseModuleSource
        else {
            return nil
        }

        var moduleSource: KinohodTicketsBookerModuleSource = .movie(id: id)

        switch kinohodBookerModuleSource {
        case "movie":
            moduleSource = .movie(id: id)
        case "cinema":
            moduleSource = .cinema(id: id)
        default:
            moduleSource = .movie(id: id)
        }

        let assembly = KinohodTicketsBookerAssembly(
            name: kinohodBookerViewName,
            moduleSource: moduleSource,
            shouldConstrainHeight: shouldConstrainHeight,
            configuration: configuration,
            sdkManager: sdkManager
        )
        bookerModule = assembly.make()
        return bookerModule
    }

    private func getLoadingDetailViewModel() -> DetailViewModel? {
        guard let detailContainerView = configuration.views[detailName] as? DetailContainerConfigView else {
            return nil
        }
        let viewModel = DetailViewModel(
            name: detailContainerView.name,
            valueForAttributeID: [:],
            configView: detailContainerView,
            otherConfigViews: self.configuration.views,
            sdkManager: self.sdkManager,
            configuration: self.configuration,
            getDistanceBlock: nil
        )
        return viewModel
    }

    func openMap() {
        sdkManager.analyticsDelegate?.selectMap(with: "knhd")
        sdkManager.analyticsDelegate?.selectInAppMap()
        sdkManager.mapDelegate?.openMap(with: id)
    }

    func sendScheduleAnalytic() {
        guard let shortTitle = viewModel.attributes["title"] as? String else {
            return
        }
        print(shortTitle)
    }

    func sendAnalytic(with type: String) {
        sdkManager.analyticsDelegate?.selectMap(with: type)
    }
}
//swiftlint:enable file_length
