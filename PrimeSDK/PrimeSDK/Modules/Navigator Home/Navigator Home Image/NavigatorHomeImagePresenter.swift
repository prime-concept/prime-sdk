import Foundation

protocol NavigatorHomeImagePresenterProtocol {
    func refresh()
    func didTap()
}

class NavigatorHomeImagePresenter: NavigatorHomeImagePresenterProtocol {
    weak var view: NavigatorHomeImageViewProtocol?

    let viewName: String
    let configuration: Configuration
    let sdkManager: PrimeSDKManagerProtocol
    let apiService: APIService
    var viewModel: NavigatorHomeImageViewModel?
    let openModuleRoutingService = OpenModuleRoutingService()

    init(
        view: NavigatorHomeImageViewProtocol,
        name: String,
        configuration: Configuration,
        apiService: APIService,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.view = view
        self.viewName = name
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.apiService = apiService
    }

    func refresh() {
        if let viewModel = NavigatorHomeImageViewModel(
            name: viewName,
            configuration: configuration,
            sdkManager: sdkManager
        ) {
            self.viewModel = viewModel
            view?.set(viewModel: viewModel)
        }
    }

    func didTap() {
        guard
            let configView = configuration.views[viewName] as? NavigatorHomeImageConfigView,
            let tapAction = configuration.actions[configView.actions.tap] as? OpenModuleConfigAction,
            let source = view?.viewController
        else {
            return
        }

        openModuleRoutingService.route(
            using: self.viewModel,
            openAction: tapAction,
            from: source,
            configuration: configuration,
            sdkManager: sdkManager
        )
    }
}
