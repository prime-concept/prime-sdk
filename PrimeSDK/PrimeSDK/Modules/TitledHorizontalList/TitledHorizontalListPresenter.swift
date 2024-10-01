import Foundation

protocol TitledHorizontalListPresenterProtocol {
    func didSelect(item: TitledHorizontalListCardViewModelProtocol)
    func tapAll()
    var loadingViewModel: TitledHorizontalListViewModel? { get }
    func didLoad()
}

class TitledHorizontalListPresenter: TitledHorizontalListPresenterProtocol {
    weak var view: TitledHorizontalListViewProtocol?
    private var viewName: String
    private var configuration: Configuration
    private var apiService: APIServiceProtocol
    private var sdkManager: PrimeSDKManagerProtocol
    private var shouldHideAll: Bool

    private var viewModel: TitledHorizontalListViewModel?

    private let locationService: LocationServiceProtocol

    lazy var loadingViewModel: TitledHorizontalListViewModel? = {
        getDummyViewModel()
    }()

    init(
        view: TitledHorizontalListViewProtocol,
        viewName: String,
        configuration: Configuration,
        apiService: APIServiceProtocol,
        sdkManager: PrimeSDKManagerProtocol,
        locationService: LocationServiceProtocol,
        shouldHideAll: Bool
//        viewModel: TitledHorizontalListViewModel?
    ) {
        self.view = view
        self.viewName = viewName
        self.configuration = configuration
        self.apiService = apiService
        self.sdkManager = sdkManager
        self.locationService = locationService
        self.shouldHideAll = shouldHideAll
//        self.viewModel = viewModel
    }

    private func getDummyViewModel() -> TitledHorizontalListViewModel? {
        let otherConfigViews = configuration.views

        guard
            let configView = configuration.views[viewName] as? TitledHorizontalListConfigView,
            let itemConfig = otherConfigViews[configView.subviews[0]]
        else {
            return nil
        }

        let viewModel = TitledHorizontalListViewModel(
            name: viewName,
            valueForAttributeID: [:],
            defaultAttributes: configView.attributes,
            itemView: itemConfig,
            sdkManager: sdkManager,
            configuration: configuration,
            shouldHideAll: false
        )
        viewModel.items = [
            HomeMoviePlainCardViewModel.dummyViewModel,
            HomeMoviePlainCardViewModel.dummyViewModel,
            HomeMoviePlainCardViewModel.dummyViewModel,
            HomeMoviePlainCardViewModel.dummyViewModel,
            HomeMoviePlainCardViewModel.dummyViewModel,
            HomeMoviePlainCardViewModel.dummyViewModel
        ]
        return viewModel
    }

    func didLoad() {
        locationService.getLocation().done { _ in
        }.catch { error in
            print("error fetch location: \(error)")
        }.finally {
            self.refresh()
        }
    }

    func tapAll() {
        guard
            let listView = configuration.views[viewName] as? TitledHorizontalListConfigView,
            let openAction = configuration.actions[listView.actions.tapAll] as? OpenModuleConfigAction
        else {
            return
        }

        sdkManager.horizontalListDelegate?.showAllPressed(for: listView.name)
        view?.open(model: viewModel, action: openAction, config: configuration, sdkManager: sdkManager)
    }

    func didSelect(item: TitledHorizontalListCardViewModelProtocol) {
        if
            let cellConfigView = configuration.views[item.viewName] as? FlatMovieCardConfigView,
            let openAction = configuration.actions[cellConfigView.actions.tap] as? OpenModuleConfigAction
        {
            view?.open(model: item, action: openAction, config: configuration, sdkManager: sdkManager)
            return
        }

        if
            let cellConfigView = configuration.views[item.viewName] as? HomeSelectionCardConfigView,
            let openAction = configuration.actions[cellConfigView.actions.tap] as? OpenModuleConfigAction
        {
            view?.open(model: item, action: openAction, config: configuration, sdkManager: sdkManager)
            return
        }
    }

    func refresh() {
        guard
            let listView = configuration.views[viewName] as? TitledHorizontalListConfigView,
            let itemConfig = configuration.views[listView.subviews[0]]
        else {
            return
        }

//        let viewModel = TitledHorizontalListViewModel(
//            name: listView.name,
//            valueForAttributeID: [:],
//            defaultAttributes: listView.attributes,
//            itemView: itemConfig,
//            sdkManager: sdkManager,
//            configuration: configuration
//        )
//
//        self.viewModel = viewModel
//
//        self.view?.update(viewModel: viewModel)

        let actionName = listView.actions.load
        guard let loadAction = configuration.actions[actionName] as? LoadConfigAction else {
            return
        }

        view?.setLoading(isLoading: true)

        loadAction.request.inject(action: loadAction.name, viewModel: viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: viewModel)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { [weak self] deserializedViewMap in
            guard let self = self else {
                return
            }
            let viewModel = TitledHorizontalListViewModel(
                name: listView.name,
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                defaultAttributes: listView.attributes,
                itemView: itemConfig,
                sdkManager: self.sdkManager,
                configuration: self.configuration,
                shouldHideAll: self.shouldHideAll,
                getDistanceBlock: { [weak self] coordinate in
                    self?.locationService.distance(to: coordinate)
                }
            )

            self.viewModel = viewModel
            self.view?.setLoading(isLoading: false)
            self.view?.update(viewModel: viewModel)
        }.catch { error in
            print("error list laoding: \(error)")
        }
    }
}
