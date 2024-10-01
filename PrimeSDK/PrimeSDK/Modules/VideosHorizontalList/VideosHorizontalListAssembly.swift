import Foundation

class VideosHorizontalListAssembly {
    var name: String
    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol
    var viewModel: VideosHorizontalListViewModel?

    init(
        name: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol,
        viewModel: VideosHorizontalListViewModel? = nil
    ) {
        self.name = name
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.viewModel = viewModel
    }

    func make() -> UIViewController {
        let controller = VideosHorizontalListViewController()
        let presenter = VideosHorizontalListPresenter(
            view: controller,
            viewName: name,
            configuration: configuration,
            apiService: APIService(sdkManager: sdkManager),
            sdkManager: sdkManager
        )
        controller.presenter = presenter
        controller.viewModel = viewModel
        return controller
    }
}
