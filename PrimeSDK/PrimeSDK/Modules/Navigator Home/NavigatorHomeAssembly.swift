import Foundation

class NavigatorHomeAssembly {
    var name: String
    var title: String
    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol

    init(
        name: String,
        title: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.name = name
        self.title = title
        self.configuration = configuration
        self.sdkManager = sdkManager
    }

    func make() -> UIViewController {
        let controller = NavigatorHomeViewController()
        controller.title = title
        let presenter = NavigatorHomePresenter(
            view: controller,
            viewName: name,
            configuration: configuration,
            apiService: APIService(sdkManager: sdkManager),
            sdkManager: sdkManager
        )
        controller.presenter = presenter
        return controller
    }
}
