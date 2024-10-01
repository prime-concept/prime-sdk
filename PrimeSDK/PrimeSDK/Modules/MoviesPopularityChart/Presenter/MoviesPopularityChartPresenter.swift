import Foundation

protocol MoviesPopularityChartPresenterProtocol {
    func refresh()
    func didSelect(item: MoviesPopularityChartItemViewModel)
    var loadingViewModel: MoviesPopularityChartViewModel? { get }
}

class MoviesPopularityChartPresenter: MoviesPopularityChartPresenterProtocol {
    weak var view: MoviesPopularityChartViewProtocol?
    private var viewName: String
    private var configuration: Configuration
    private var apiService: APIServiceProtocol
    private var sdkManager: PrimeSDKManagerProtocol
    private var viewModel: MoviesPopularityChartViewModel?

    lazy var loadingViewModel: MoviesPopularityChartViewModel? = {
        getDummyViewModel()
    }()

    init(
        view: MoviesPopularityChartViewProtocol,
        viewName: String,
        configuration: Configuration,
        apiService: APIServiceProtocol,
        sdkManager: PrimeSDKManagerProtocol,
        viewModel: MoviesPopularityChartViewModel?
    ) {
        self.view = view
        self.viewName = viewName
        self.configuration = configuration
        self.apiService = apiService
        self.sdkManager = sdkManager
        self.viewModel = viewModel
    }

    private func getDummyViewModel() -> MoviesPopularityChartViewModel? {
        guard
            let configView = configuration.views[viewName] as? MoviesPopularityChartConfigView,
            let itemConfig = configuration.views[configView.subviews[0]] as? PopularityChartRowConfigView
        else {
            return nil
        }

        let viewModel = MoviesPopularityChartViewModel(
            name: viewName,
            valueForAttributeID: [:],
            defaultAttributes: configView.attributes,
            itemView: itemConfig,
            sdkManager: sdkManager,
            configuration: configuration
        )
        viewModel.items = [
            MoviesPopularityChartItemViewModel.dummyViewModel,
            MoviesPopularityChartItemViewModel.dummyViewModel,
            MoviesPopularityChartItemViewModel.dummyViewModel,
            MoviesPopularityChartItemViewModel.dummyViewModel,
            MoviesPopularityChartItemViewModel.dummyViewModel
        ]
        return viewModel
    }

    // MARK: - MoviesPopularityChartPresenterProtocol
    func didSelect(item: MoviesPopularityChartItemViewModel) {
        guard
            let sectionCellConfigView = configuration.views[item.viewName] as? PopularityChartRowConfigView
        else {
            return
        }

        if
            let openAction = configuration.actions[sectionCellConfigView.actions.tap] as? OpenModuleConfigAction
        {
            view?.open(model: item, action: openAction, config: configuration, sdkManager: sdkManager)
        }
    }

    func refresh() {
        guard
            let listView = configuration.views[viewName] as? MoviesPopularityChartConfigView,
            let itemConfig = configuration.views[listView.subviews[0]] as? PopularityChartRowConfigView
        else {
            return
        }

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

            let viewModel = MoviesPopularityChartViewModel(
                name: listView.name,
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                defaultAttributes: listView.attributes,
                itemView: itemConfig,
                sdkManager: self.sdkManager,
                configuration: self.configuration
            )

            self.viewModel = viewModel
            self.view?.setLoading(isLoading: false)
            self.view?.update(viewModel: viewModel)
        }.cauterize()
    }
}
