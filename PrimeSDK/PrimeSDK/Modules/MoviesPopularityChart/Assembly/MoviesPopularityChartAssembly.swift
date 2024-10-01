import Foundation

class MoviesPopularityChartAssembly {
    var name: String
    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol
    var viewModel: MoviesPopularityChartViewModel?

    init(
        name: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol,
        viewModel: MoviesPopularityChartViewModel?
    ) {
        self.name = name
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.viewModel = viewModel
    }

    func make() -> UIViewController {
        let controller = MoviesPopularityChartViewController()
        let presenter = MoviesPopularityChartPresenter(
            view: controller,
            viewName: name,
            configuration: configuration,
            apiService: APIService(sdkManager: sdkManager),
            sdkManager: sdkManager,
            viewModel: viewModel
        )
        controller.presenter = presenter
        return controller
    }
}
