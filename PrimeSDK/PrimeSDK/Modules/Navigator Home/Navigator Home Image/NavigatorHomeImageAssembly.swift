import Foundation

class NavigatorHomeImageAssembly {
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
        let controller = NavigatorHomeImageViewController()
        let presenter = NavigatorHomeImagePresenter(
            view: controller,
            name: name,
            configuration: configuration,
            apiService: APIService(sdkManager: sdkManager),
            sdkManager: sdkManager
        )
        controller.presenter = presenter
        return controller
    }
}
