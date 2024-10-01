import Foundation
import PromiseKit
import YandexMobileAds

extension Notification.Name {
    static let listCoordinateSet = Notification.Name("listCoordinateSet")
}

class ListPresenter: AnyListPresenter {
    private var apiService: APIService
    private let listName: String
    private let viewConfiguration: ListConfigView
    private var sdkManager: PrimeSDKManagerProtocol
    private let locationService: LocationServiceProtocol
    private let sharingService: SharingServiceProtocol
    private let limit = 10
    private let id: String?

    private var configuration: Configuration
    private var attributesForCellName: [String: Any] = [:]
    private var supportedCells: [String] {
        return viewConfiguration.subviews
    }
    private var viewModel = ListViewModel.empty

    private var currentRequestCancellationToken: (() -> Void)?

    override func itemSizeType() -> ItemSizeType {
        return ItemSizeType.custom(
            height: CGFloat(viewConfiguration.attributes.itemHeight ?? 0),
            width: 0,
            overlapDelta: 0
        )
    }

    override var name: String {
        return listName
    }

    override var canViewLoadNewPage: Bool {
        return viewConfiguration.attributes.supportPagination && hasNextPage
    }
    override var hasHeader: Bool {
        return viewConfiguration.attributes.hasHeader
    }

    override var allowsPullToRefresh: Bool {
        return viewConfiguration.attributes.allowsPullToRefresh
    }

    override var listDelegate: PrimeSDKListDelegate? {
        return sdkManager.listDelegate
    }

    override var supportAutoItemHeight: Bool {
        return viewConfiguration.attributes.supportAutoItemHeight
    }

    override var shouldHideScrollIndicator: Bool {
        return viewConfiguration.attributes.shouldHideScrollIndicator
    }

    private var hasNextPage: Bool = true

    var isRouteToAuth: Bool = false

    weak var view: AnyListView?

    //common
    private var currentTagIndex: Int?

    var currentPage: Int?

    private var needsToLoadFromCache: Bool = true

    private var listItemViewModelFactory: ListItemViewModelFactory

    //Analytics properties
//    var appearanceEvent: AnalyticsEvent?

//    var adService: AdServiceProtocol

    init(
        view: AnyListView,
//        adService: AdServiceProtocol,
//        appearanceEvent: AnalyticsEvent?,
        listName: String,
        id: String?,
        configuration: Configuration,
        apiService: APIService,
        locationService: LocationServiceProtocol,
        sharingService: SharingServiceProtocol,
        attributesForCellName: [String: Any],
        viewConfiguration: ListConfigView,
        sdkManager: PrimeSDKManagerProtocol,
        listItemViewModelFactory: ListItemViewModelFactory
    ) {
        self.view = view
        self.id = id
//        self.adService = adService
//        self.appearanceEvent = appearanceEvent
        self.configuration = configuration
        self.apiService = apiService
        self.view = view
        self.listName = listName
        self.attributesForCellName = attributesForCellName
        self.viewConfiguration = viewConfiguration
        self.sdkManager = sdkManager
        self.locationService = locationService
        self.sharingService = sharingService
        self.listItemViewModelFactory = listItemViewModelFactory
        super.init()

        self.registerForNotifications()
        self.viewModel.itemWidth = UIScreen.main.bounds.width
        self.viewModel.itemHeight = itemSizeType().itemHeight
        self.sdkManager.reloadBlockForListName[listName] = { [weak self] show in
            try? self?.load(showingIndicator: show)
        }

        self.sdkManager.reloadCollectionDataForListName[listName] = { [weak self] in
            self?.view?.reloadData()
        }

        self.startListeningForLocationAuthorization()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let token = adbanToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    func load(showingIndicator: Bool = false) throws {
        guard self.listView != nil else {
            return
        }

        hasNextPage = true

        self.view?.setScrollIndicatorVisibilty(shouldHideScrollIndicator)

        if showingIndicator {
            self.view?.set(state: .loading)
            self.view?.setPagination(state: .none)
        }

        getLocationThen { [weak self] coordinate in
            self?.load(page: 1, coordinate: coordinate)
        }
    }

    private var listView: ListConfigView? {
        configuration.views[listName] as? ListConfigView
    }

    private func getLocationThen(_ completion: @escaping (GeoCoordinate?) -> Void) {
        guard let listView = self.listView else {
            completion(nil)
            return
        }

        if listView.attributes.allowsLocation {
            locationService.getLocation().done { coordinate in
                completion(coordinate)
            }.catch { _ in
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }

    private func displayData(deserializedViewMap: DeserializedViewMap, forPage page: Int) {
        var newData: [ListItemViewModelProtocol] = []

        let res = self.makeViewModelsForCells(
            deserializedViewMap: deserializedViewMap
        )
        newData += res.0
        self.viewModel.header = res.1
        if page == 1 {
            self.viewModel.data = []
        }

        if newData.isEmpty {
            self.hasNextPage = false
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view?.set(state: strongSelf.viewModel.data.isEmpty ? .empty : .normal)
                strongSelf.view?.setPagination(state: .none)
                strongSelf.view?.update(viewModel: strongSelf.viewModel)
            }
            return
        }

        if page == 1 {
           self.viewModel.data = newData
        } else {
            self.viewModel.data += newData
        }
        self.currentPage = page

        self.hasNextPage = !newData.isEmpty

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view?.update(viewModel: strongSelf.viewModel)
            strongSelf.view?.set(state: strongSelf.viewModel.data.isEmpty ? .empty : .normal)
            strongSelf.view?.setPagination(state: .none)
        }
    }

    private func load(page: Int, coordinate: GeoCoordinate? = nil) {
        let actionName = viewConfiguration.actions.load

        guard let loadListAction = configuration.actions[actionName] as? LoadConfigAction else {
            return
        }

        updateLocationHeaders(coordinate)

        DataStorage.shared.set(value: id, for: "id", in: actionName)
        DataStorage.shared.set(value: limit, for: "limit", in: loadListAction.name)
        DataStorage.shared.set(value: limit * (page - 1), for: "offset", in: loadListAction.name)
        DataStorage.shared.set(value: page, for: "page", in: actionName)

        loadListAction.request.inject(action: loadListAction.name, viewModel: viewModel)
        loadListAction.response.inject(action: loadListAction.name, viewModel: viewModel)

        if page == 1 && viewModel.data.isEmpty {
            view?.set(state: .loading)
        }

        if
            let cachedResponse = sdkManager.apiDelegate?.getCachedResponse(configRequest: loadListAction.request)
        {
            loadListAction.response.deserializer?.deserialize(
                json: cachedResponse
            ).done { [weak self] deserializedViewMap in
                if self?.needsToLoadFromCache == true {
                    self?.displayData(deserializedViewMap: deserializedViewMap, forPage: page)
                }
            }.cauterize()
        }

        currentRequestCancellationToken?()

        let request = apiService.request(
            action: loadListAction.name,
            configRequest: loadListAction.request,
            configResponse: loadListAction.response,
            sdkDelegate: sdkManager.apiDelegate
        )

        currentRequestCancellationToken = request.cancel

        request
            .promise
            .done { [weak self] deserializedViewMap in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.needsToLoadFromCache = false
                strongSelf.displayData(deserializedViewMap: deserializedViewMap, forPage: page)
            }
            .catch { [weak self] error in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.sdkManager.analyticsDelegate?.listOpenedError(
                    viewName: strongSelf.listName,
                    error: nil
                )
                if let error = error as? BackendGeneratedError, strongSelf.viewModel.data.isEmpty {
                    self?.view?.set(state: .error(text: error.localizedDescription))
                }
            }
    }

    private func makeViewModelsForCells(
        deserializedViewMap: DeserializedViewMap
    ) -> ([ListItemViewModelProtocol], ListHeaderViewModel?) {
        var newData: [ListItemViewModelProtocol] = []
        var listHeader: ListHeaderViewModel?

        guard let cellName = supportedCells.first else {
            fatalError("Should have been checked in config")
        }

        let valuesForCellType = deserializedViewMap.valueForAttributeID.filter {
            $0.key.range(of: cellName)?.lowerBound == $0.key.startIndex
        }
        let headerValueForAttribute = deserializedViewMap.valueForAttributeID.filter { $0.key.hasPrefix("header") }
        listHeader = try? ListHeaderViewModel(valueForAttributeID: headerValueForAttribute)

        let count = valuesForCellType.keys.reduce(0) { (curCount, key) -> Int in
            let tokens = key.components(separatedBy: ".")
            if tokens.count > 2 {
                if let index = Int(tokens[1]) {
                    return max(curCount, index + 1)
                }
            }
            return curCount
        }
        for cellIndex in 0 ..< count {
            var valuesForCell = valuesForCellType.compactMap { (record) -> (String, Any)? in
                if let keyRange = record.key.range(of: "\(cellName).\(cellIndex).") {
                    var mutableKey = record.key
                    mutableKey.removeSubrange(keyRange)
                    return (mutableKey, record.value)
                }
                return nil
            }
            valuesForCell.append(("listName", listName))
            let dict: [String: Any] = Dictionary(uniqueKeysWithValues: valuesForCell)
            let attributes = attributesForCellName[cellName] as? ListItemConfigView.Attributes

            if let configView = configuration.views[cellName] {
                let viewModel = listItemViewModelFactory.makeViewModel(
                    from: configView,
                    valueForAttributeID: dict,
                    defaultAttributes: attributes,
                    position: cellIndex,
                    getDistanceBlock: { [weak self] coordinate in
                        self?.locationService.distance(to: coordinate)
                    },
                    sdkManager: sdkManager,
                    configuration: configuration
                )

                newData += [viewModel]
            }
        }

        return (newData, listHeader)
    }

    override func getDummyViewModel() -> ListViewModel {
        if viewModel.data.isEmpty {
            let items = [
                getDummyItemViewModel(),
                getDummyItemViewModel(),
                getDummyItemViewModel(),
                getDummyItemViewModel(),
                getDummyItemViewModel(),
                getDummyItemViewModel(),
                getDummyItemViewModel(),
                getDummyItemViewModel(),
                getDummyItemViewModel(),
                getDummyItemViewModel()
            ]
            viewModel.data = items
        }
        return viewModel
    }

    private func getDummyItemViewModel() -> ListItemViewModelProtocol {
        guard let cellName = supportedCells.first else {
            fatalError("Should have been checked in config")
        }

        let attributes = attributesForCellName[cellName] as? ListItemConfigView.Attributes

        if let configView = configuration.views[cellName] {
            return listItemViewModelFactory.makeViewModel(
                from: configView,
                valueForAttributeID: [:],
                defaultAttributes: attributes,
                position: nil,
                sdkManager: sdkManager,
                configuration: configuration
            )
        }

        fatalError("Should have been checked in config")
    }

    func getItemViewModel() {
    }

    private func registerForNotifications() {
    }

    @objc
    private func handleLoginAndLogout() {
        self.refresh()
    }

    override func didAppear() {
//        appearanceEvent?.send()
    }

    private func handleError() {
//        view?.showError(text: LS.localize("NoInternetConnection"))
        view?.showError(text: "No internet connection")
//        view?.set(state: items.isEmpty ? .empty : .normal)
    }

    private func loadDataWithCoords() {
//        locationService.getLocation().done { [weak self] coordinate in
//            self?.refreshedCoordinate = coordinate
//            self?.refreshItems()
//        }.catch { [weak self] _ in
//            self?.refreshItems()
//            print("Unable to get location")
//        }
    }

    override func willAppear() {
        if isRouteToAuth {
            isRouteToAuth = false
            refresh()
        }
    }

    override func refresh() {
        do {
            try load()
        } catch {
            view?.showError(text: error.localizedDescription)
        }
    }


    override func selectItem(at index: Int) {
        var openActionName: String?
        let configView = configuration.views[viewModel.data[index].viewName]

        if let cellConfigView = configView as? ListItemConfigView {
            openActionName = cellConfigView.actions.tap
        } else if let cellConfigView = configView as? MovieNowConfigView {
            openActionName = cellConfigView.actions.tap
        } else if let cellConfigView = configView as? CinemaCardConfigView {
            openActionName = cellConfigView.actions.tap
        }

        let selectedViewModel: ViewModelProtocol = viewModel.data[index]

        if
            let openActionName = openActionName,
            let openAction = configuration.actions[openActionName] as? OpenModuleConfigAction
        {
            view?.open(model: selectedViewModel, action: openAction, config: configuration, sdkManager: sdkManager)
        }
    }

    override func loadNextPage() {
        getLocationThen { [weak self] coordinate in
            guard let self = self else {
                return
            }
            self.view?.setPagination(state: .loading)
            self.load(page: (self.currentPage ?? 0) + 1, coordinate: coordinate)
        }
    }

    private func refreshItems(shouldShowLoadingIndicator: Bool = true) {
        currentPage = nil
        if shouldShowLoadingIndicator {
            view?.set(state: .loading)
        }
        getLocationThen { [weak self] coordinate in
            self?.load(page: 1, coordinate: coordinate)
        }
    }

    func cacheItems() {
    }

    func loadCached() {
    }

    private func updateLocationHeaders(_ coordinate: GeoCoordinate?) {
        guard let listView = configuration.views[listName] as? ListConfigView else {
            return
        }
        let loadAction = listView.actions.load

        if let coordinate = coordinate {
            let lat = String(describing: coordinate.latitude)
            let lon = String(describing: coordinate.longitude)

            DataStorage.shared.set(value: lat, for: "lat", in: loadAction)
            DataStorage.shared.set(value: lon, for: "lon", in: loadAction)
        } else {
            DataStorage.shared.set(value: nil, for: "lat", in: loadAction)
            DataStorage.shared.set(value: nil, for: "lon", in: loadAction)
        }
    }

    private var adbanToken: NSObjectProtocol?

    private func startListeningForLocationAuthorization() {
        let key = "LIST_PRESENTER_LOCATION_SERVICE_ENABLED"
        let status = locationService.locationServiceEnabled()
        UserDefaults.standard.setValue(status, forKey: key)

        let name = UIApplication.didBecomeActiveNotification
        adbanToken = NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }

            let previousStatus = UserDefaults.standard.bool(forKey: key)
            let status = self.locationService.locationServiceEnabled()
            if status == true, previousStatus != status {
                self.refresh()
            }
            UserDefaults.standard.setValue(status, forKey: key)
        }
    }
}
