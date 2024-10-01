import Foundation

class HorizontalListsContainerAssembly {
    var name: String
    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol

    init(name: String, configuration: Configuration, sdkManager: PrimeSDKManagerProtocol) {
        self.name = name
        self.configuration = configuration
        self.sdkManager = sdkManager
    }

    func make() -> UIViewController {
        let controller = HorizontalListsContainerViewController()
        let presenter = HorizontalListsContainerPresenter(
            view: controller,
            viewName: name,
            configuration: self.configuration,
            sdkManager: self.sdkManager,
            apiService: APIService(sdkManager: sdkManager),
            locationService: LocationService(),
            openModuleRoutingService: OpenModuleRoutingService()
        )
        controller.presenter = presenter
        return controller
    }
}
