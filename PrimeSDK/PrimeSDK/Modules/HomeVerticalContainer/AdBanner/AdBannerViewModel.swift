import Foundation
import UIKit
import YandexMobileAds

class AdBannerViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    weak var delegate: AdBannerDelegate?
    var sdkManager: PrimeSDKManagerProtocol
    var imageAd: YMANativeImageAd?
    var height: Float

    init(
        name: String,
        configView: AdBannerConfigView,
        sdkManager: PrimeSDKManagerProtocol,
        delegate: AdBannerDelegate?,
        imageAd: YMANativeImageAd? = nil,
        height: CGFloat? = nil
    ) {
        self.viewName = name
        self.imageAd = imageAd
        self.sdkManager = sdkManager
        self.height = configView.attributes.height
        if let height = height {
            self.height = Float(height)
        }
        self.configView = configView
        self.delegate = delegate
    }

    var configView: AdBannerConfigView
}

extension AdBannerViewModel: HomeContainerBlockViewModelProtocol {
    var width: NavigatorHomeElementWidth {
        .full
    }

    func makeViewController() -> UIViewController {
        let assembly = AdBannerAssembly(
            name: viewName,
            configView: configView,
            viewModel: self
        )
        return assembly.make()
    }

    func makeModule() -> HomeBlockModule? {
        return .viewController(makeViewController())
    }
}
