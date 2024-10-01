import Foundation
import PromiseKit

protocol HorizontalListsContainerViewProtocol: AnyObject {
    func update(viewModel: HorizontalListsContainerViewModel)
    var viewController: UIViewController { get }
}

class HorizontalListsContainerPresenter: HorizontalListsContainerPresenterProtocol {
    weak var view: HorizontalListsContainerViewProtocol?
    private var configuration: Configuration
    private var viewName: String
    private var sdkManager: PrimeSDKManagerProtocol
    private var apiService: APIServiceProtocol
    private var locationService: LocationServiceProtocol
    private var openModuleRoutingService: OpenModuleRoutingService

    private var viewModel = HorizontalListsContainerViewModel()

    var cancellationTokens: [() -> Void] = []

    init(
        view: HorizontalListsContainerViewProtocol,
        viewName: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol,
        apiService: APIServiceProtocol,
        locationService: LocationServiceProtocol,
        openModuleRoutingService: OpenModuleRoutingService
    ) {
        self.view = view
        self.viewName = viewName
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.apiService = apiService
        self.locationService = locationService
        self.openModuleRoutingService = openModuleRoutingService

        self.sdkManager.cancelRequestsForName[viewName] = { [weak self] in
            while let cancel = self?.cancellationTokens.popLast() {
                cancel()
            }
        }
        self.sdkManager.reloadHorizontalListsContainerForName[viewName] = { [weak self] in
            self?.refresh()
        }
    }

    func refresh() {
        guard let listsContainerView = configuration.views[viewName] as? HorizontalListsContainerConfigView else {
            return
        }

        self.viewModel = HorizontalListsContainerViewModel(
            name: viewName,
            valueForAttributeID: [:],
            configView: listsContainerView,
            otherConfigViews: configuration.views,
            sdkManager: sdkManager,
            configuration: configuration
        )
        self.view?.update(viewModel: viewModel)

        self.loadRows().done { [weak self] items in
            guard let self = self else {
                return
            }

            for item in items {
                self.viewModel.update(block: item, name: item.viewName)
                self.view?.update(viewModel: self.viewModel)
            }
        }.cauterize()
    }

    private func loadRows() -> Promise<[DetailHorizontalItemsViewModel]> {
        var promises = [Promise<DetailHorizontalItemsViewModel>]()
        for subview in viewModel.subviews {
            let name = subview.viewName
            guard let detailHorizontalListView = configuration.views[name] as? DetailHorizontalListConfigView else {
                continue
            }

            if detailHorizontalListView.attributes.allowsLocation {
                locationService.getLocation().done { coordinate in
                    let promise = self.loadHorizontalRow(
                        name: subview.viewName,
                        coordinate: coordinate,
                        detailHorizontalListView: detailHorizontalListView
                    )
                    promises.append(promise)
                }.catch { _ in
                    let promise = self.loadHorizontalRow(
                        name: subview.viewName,
                        coordinate: nil,
                        detailHorizontalListView: detailHorizontalListView
                    )
                    promises.append(promise)
                }
            } else {
                let promise = self.loadHorizontalRow(
                    name: subview.viewName,
                    coordinate: nil,
                    detailHorizontalListView: detailHorizontalListView
                )
                promises.append(promise)
            }
        }
        return Promise { seal in
            when(fulfilled: promises).done { models in
                seal.fulfill(models)
            }.catch { error in
                print("error while fetching search items: \(error.localizedDescription)")
            }
        }
    }

    private func loadHorizontalRow(
        name: String,
        coordinate: GeoCoordinate?,
        detailHorizontalListView: DetailHorizontalListConfigView
    ) -> Promise<DetailHorizontalItemsViewModel> {
        return Promise { seal in
            guard let itemView = configuration.views[detailHorizontalListView.item] as? ListItemConfigView else {
                return
            }

            let actionName = detailHorizontalListView.actions.load
            guard let loadAction = configuration.actions[actionName] as? LoadConfigAction else {
                return
            }

            DataStorage.shared.set(value: "5bbf3fcd9cdeca00226fd868", for: "id", in: actionName)
            DataStorage.shared.set(value: coordinate?.latitude ?? "", for: "lat", in: actionName)
            DataStorage.shared.set(value: coordinate?.longitude ?? "", for: "lon", in: actionName)

            loadAction.request.inject(action: loadAction.name, viewModel: nil)
            loadAction.response.inject(action: loadAction.name, viewModel: nil)

            let request = apiService.request(
                action: loadAction.name,
                configRequest: loadAction.request,
                configResponse: loadAction.response,
                sdkDelegate: sdkManager.apiDelegate
            )
            cancellationTokens += [request.cancel]

            request.promise.done { [weak self] deserializedViewMap in
                guard let strongSelf = self else {
                    return
                }

                guard let horizontalItemsViewModel = try? DetailHorizontalItemsViewModel(
                    viewName: detailHorizontalListView.name,
                    valueForAttributeID: deserializedViewMap.valueForAttributeID,
                    listConfigView: detailHorizontalListView,
                    itemView: itemView,
                    getDistanceBlock: nil,
                    sdkManager: strongSelf.sdkManager,
                    configuration: strongSelf.configuration
                ) else {
                    return
                }

                seal.fulfill(horizontalItemsViewModel)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func horizontalItemPressed(list: String, position: Int) {
        guard let viewModel = viewModel.subviewForName[list] else {
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
}
