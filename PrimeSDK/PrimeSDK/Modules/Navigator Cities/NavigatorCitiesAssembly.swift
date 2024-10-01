import Foundation

class NavigatorCitiesAssembly {
    var name: String
    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol

    init(
        name: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.name = name
        self.configuration = configuration
        self.sdkManager = sdkManager
    }

    func make() -> UIViewController {
        let controller = NavigatorCitiesViewController()
        let presenter = NavigatorCitiesPresenter(
            viewName: name,
            view: controller,
            configuration: configuration,
            apiService: APIService(sdkManager: self.sdkManager),
            locationService: LocationService(),
            openModuleRoutingService: OpenModuleRoutingService(),
            sdkManager: sdkManager
        )
        controller.presenter = presenter
        return controller
    }
}
