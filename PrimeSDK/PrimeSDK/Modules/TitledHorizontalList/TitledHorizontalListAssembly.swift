import Foundation

class TitledHorizontalListAssembly {
    var name: String
    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol
    var viewModel: TitledHorizontalListViewModel?
    var shouldHideAll: Bool

    init(
        name: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol,
        shouldHideAll: Bool
    ) {
        self.name = name
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.shouldHideAll = shouldHideAll
//        self.viewModel = viewModel
    }

    func make() -> UIViewController {
        let controller = TitledHorizontalListViewController()
        let presenter = TitledHorizontalListPresenter(
            view: controller,
            viewName: name,
            configuration: configuration,
            apiService: APIService(sdkManager: sdkManager),
            sdkManager: sdkManager,
            locationService: LocationService(),
            shouldHideAll: shouldHideAll
//            viewModel: viewModel
        )
        controller.presenter = presenter
        return controller
    }
}
