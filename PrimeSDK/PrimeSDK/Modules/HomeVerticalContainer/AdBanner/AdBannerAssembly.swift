import Foundation

class AdBannerAssembly {
    var name: String
    var configView: AdBannerConfigView
    var viewModel: AdBannerViewModel

    init(
        name: String,
        configView: AdBannerConfigView,
        viewModel: AdBannerViewModel
    ) {
        self.name = name
        self.configView = configView
        self.viewModel = viewModel
    }

    func make() -> UIViewController {
        let controller = AdBannerViewController()
        let presenter = AdBannerPresenter(
            view: controller,
            viewName: name,
            configView: configView,
            adService: AdService(sdkManager: viewModel.sdkManager),
            viewModel: viewModel,
            delegate: viewModel.delegate
        )
        controller.presenter = presenter
        return controller
    }
}
