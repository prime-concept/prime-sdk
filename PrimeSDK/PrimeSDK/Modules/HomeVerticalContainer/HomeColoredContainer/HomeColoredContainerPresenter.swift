import Alamofire
import Foundation

protocol HomeColoredContainerPresenterProtocol {
    func refresh()
}

class HomeColoredContainerPresenter: HomeColoredContainerPresenterProtocol {
    weak var view: HomeColoredContainerViewProtocol?
    private var viewName: String
    private var configuration: Configuration
    private var sdkManager: PrimeSDKManagerProtocol

    init(
        view: HomeColoredContainerViewProtocol,
        viewName: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.view = view
        self.viewName = viewName
        self.configuration = configuration
        self.sdkManager = sdkManager

        self.sdkManager.reloadBlockForListName[viewName] = { [weak self] show in
            self?.refresh()
        }
    }

    func refresh() {
        guard let configView = configuration.views[viewName] as? HomeColoredContainerConfigView else {
            return
        }

        guard var viewModel = HomeColoredContainerViewModel(
            name: configView.name,
            valueForAttributeID: [:],
            configView: configView,
            sdkManager: sdkManager,
            configuration: configuration
        ) else {
            return
        }

        for subview in viewModel.subviews {
            if let titledHorizontalList = subview as? TitledHorizontalListViewModel {
                titledHorizontalList.configuration = configuration
                titledHorizontalList.sdkManager = sdkManager
                viewModel.subviewForName[titledHorizontalList.viewName] = titledHorizontalList
            }

            if let adBannerView = subview as? AdBannerViewModel {
                viewModel.subviewForName[adBannerView.viewName] = adBannerView
                adBannerView.delegate = self
            }

            if let filterHorizontalList = subview as? FilterHorizontalListViewModel {
                filterHorizontalList.configuration = configuration
                filterHorizontalList.sdkManager = sdkManager
                viewModel.subviewForName[filterHorizontalList.viewName] = filterHorizontalList
            }

            if let moviesPopularityChart = subview as? MoviesPopularityChartViewModel {
                moviesPopularityChart.configuration = configuration
                moviesPopularityChart.sdkManager = sdkManager
                viewModel.subviewForName[moviesPopularityChart.viewName] = moviesPopularityChart
            }
        }
        view?.update(viewModel: viewModel)
    }
}

extension HomeColoredContainerPresenter: AdBannerDelegate {
    func heightShouldChange() {
        //TODO: Refresh view height if needed
    }
}

