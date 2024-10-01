import Foundation

class KinohodSearchAssembly {
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
        let controller = KinohodSearchViewController()
        let presenter = KinohodSearchPresenter(
            view: controller,
            viewName: name,
            configuration: configuration,
            apiService: APIService(sdkManager: sdkManager),
            locationService: LocationService(),
            sdkManager: sdkManager
        )
        controller.presenter = presenter
        return controller
    }
}
