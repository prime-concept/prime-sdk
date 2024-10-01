import Foundation
import PromiseKit

protocol NavigatorCitiesPresenterProtocol {
    func refresh()
    func loadNextPage()
    func select(city: NavigatorCityViewModel)
    func changeQuery(toQuery: String?)
}

class NavigatorCitiesPresenter: NavigatorCitiesPresenterProtocol {
    weak var view: NavigatorCitiesViewProtocol?

    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol
    var apiService: APIServiceProtocol
    var locationService: LocationServiceProtocol
    var openModuleRoutingService: OpenModuleRoutingService

    var loadAction: LoadConfigAction
    var configView: NavigatorCitiesConfigView

    var viewModel: NavigatorCitiesViewModel

    var refreshedCoordinate: GeoCoordinate?

    var page: Int = 1
    var isLastPage: Bool = false

    var currentRequest: (promise: Promise<DeserializedViewMap>, cancel: () -> Void)?

    init?(
        viewName: String,
        view: NavigatorCitiesViewProtocol,
        configuration: Configuration,
        apiService: APIServiceProtocol,
        locationService: LocationServiceProtocol,
        openModuleRoutingService: OpenModuleRoutingService,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.view = view
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.apiService = apiService
        self.locationService = locationService
        self.openModuleRoutingService = openModuleRoutingService

        guard
            let configView = configuration.views[viewName] as? NavigatorCitiesConfigView,
            let loadAction = configuration.actions[configView.actions.load] as? LoadConfigAction
        else {
            return nil
        }

        self.configView = configView
        self.loadAction = loadAction

        self.viewModel = NavigatorCitiesViewModel(name: viewName)
    }

    func refresh() {
        view?.set(title: configView.attributes.title)
        load(page: 1)
    }

    func loadNextPage() {
        load(page: page + 1)
    }

    func select(city: NavigatorCityViewModel) {
        guard
            let tapAction = configuration.actions[configView.actions.tap] as? OpenModuleConfigAction,
            let source = view?.viewController
        else {
            return
        }

        DataStorage.shared.set(value: city.id, for: "city_id")

        openModuleRoutingService.route(
            using: city,
            openAction: tapAction,
            from: source,
            configuration: configuration,
            sdkManager: sdkManager
        )
    }

    func changeQuery(toQuery: String?) {
        viewModel.query = toQuery
        view?.update(viewModel: viewModel)
    }

    private func load(page: Int) {
        locationService.getLocation().done { [weak self] coordinate in
            self?.refreshedCoordinate = coordinate
            self?.loadWithCoordinate(page: page)
        }.catch { [weak self] _ in
            self?.loadWithCoordinate(page: page)
        }
    }

    private func loadWithCoordinate(page: Int) {
        if page != 1 && (currentRequest != nil || isLastPage) {
            return
        }

        if page == 1 {
            currentRequest?.cancel()
            currentRequest = nil

            view?.set(state: viewModel.cities.isEmpty ? .refreshing : .loadingNewPage)
        }

        DataStorage.shared.set(value: page, for: "page", in: loadAction.name)
        DataStorage.shared.set(value: refreshedCoordinate?.latitude ?? "", for: "lat", in: loadAction.name)
        DataStorage.shared.set(value: refreshedCoordinate?.longitude ?? "", for: "lon", in: loadAction.name)

        loadAction.request.inject(action: loadAction.name, viewModel: viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: viewModel)

        currentRequest = apiService
            .request(
                action: loadAction.name,
                configRequest: loadAction.request,
                configResponse: loadAction.response,
                sdkDelegate: sdkManager.apiDelegate
            )

        currentRequest?
            .promise
            .done { [weak self] deserializedViewMap in
                guard let self = self else {
                    return
                }
                let prevCount = self.viewModel.cities.count
                if page == 1 {
                    self.viewModel.reloadCities(valueForAttributeID: deserializedViewMap.valueForAttributeID)
                } else {
                    self.viewModel.addCities(valueForAttributeID: deserializedViewMap.valueForAttributeID)
                }
                if self.viewModel.cities.count == prevCount {
                    self.isLastPage = true
                } else {
                    self.isLastPage = false
                    self.page = page
                }
                self.view?.set(state: self.viewModel.cities.isEmpty ? .empty : .data)
                self.view?.update(viewModel: self.viewModel)
                self.currentRequest = nil
            }
            .catch { [weak self] _ in
                guard let self = self else {
                    return
                }

                self.currentRequest = nil
                self.view?.set(state: self.viewModel.cities.isEmpty ? .error : .errorLoadingNewPage )

                //TODO: Update empty state here?

//                if let error = error as? BackendGeneratedError, strongSelf.viewModel.data.isEmpty {
//                    self?.view?.set(state: .error(text: error.localizedDescription))
//                }
            }
    }
}
