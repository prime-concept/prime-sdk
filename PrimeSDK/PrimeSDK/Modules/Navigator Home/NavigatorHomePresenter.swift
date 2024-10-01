import Foundation

protocol NavigatorHomePresenterProtocol {
    func refresh()
}

class NavigatorHomePresenter: NavigatorHomePresenterProtocol {
    weak var view: NavigatorHomeViewProtocol?

    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol
    var apiService: APIService
    var viewName: String

    init(
        view: NavigatorHomeViewProtocol,
        viewName: String,
        configuration: Configuration,
        apiService: APIService,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.view = view
        self.viewName = viewName
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.apiService = apiService
    }

    func refresh() {
        guard let configView = configuration.views[viewName] as? NavigatorHomeConfigView else {
            return
        }

        guard let viewModel = NavigatorHomeViewModel(
            name: configView.name,
            valueForAttributeID: [:],
            configView: configView,
            configuration: configuration,
            sdkManager: sdkManager
        ) else {
            return
        }

        for subview in viewModel.subviews {
            if let titledHorizontalList = subview as? NavigatorHomeImageViewModel {
                titledHorizontalList.configuration = configuration
                titledHorizontalList.sdkManager = sdkManager
                viewModel.subviewForName[titledHorizontalList.viewName] = titledHorizontalList
            }
        }

        view?.update(viewModel: viewModel)
    }
}
