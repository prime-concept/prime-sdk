import Foundation

class FilterHorizontalListAssembly {
    var name: String
    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol
    var viewModel: FilterHorizontalListViewModel

    init(
        name: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol,
        viewModel: FilterHorizontalListViewModel
    ) {
        self.name = name
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.viewModel = viewModel
    }

    func make() -> UIViewController {
        let controller = FilterHorizontalListViewController()
        let presenter = FilterHorizontalListPresenter(
            view: controller,
            viewName: name,
            configuration: self.configuration,
            sdkManager: self.sdkManager,
            viewModel: viewModel
        )
        controller.presenter = presenter
        return controller
    }
}
