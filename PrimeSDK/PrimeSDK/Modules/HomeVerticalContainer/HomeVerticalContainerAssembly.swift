import Foundation

class HomeVerticalContainerAssembly {
    var name: String
    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol

    init(name: String, configuration: Configuration, sdkManager: PrimeSDKManagerProtocol) {
        self.name = name
        self.configuration = configuration
        self.sdkManager = sdkManager
    }

    func make() -> UIViewController {
        let controller = HomeVerticalContainerViewController()
        let presenter = HomeVerticalContainerPresenter(
            apiService: APIService(sdkManager: sdkManager),
            view: controller,
            viewName: name,
            configuration: configuration,
            sdkManager: sdkManager
        )
        controller.presenter = presenter
        return controller
    }
}
