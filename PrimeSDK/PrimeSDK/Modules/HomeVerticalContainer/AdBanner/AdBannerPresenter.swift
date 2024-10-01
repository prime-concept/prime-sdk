import Foundation
import YandexMobileAds

protocol AdBannerViewProtocol: AnyObject {
    func set(viewModel: AdBannerViewModel)
}

protocol AdBannerPresenterProtocol: AnyObject {
    func refresh()
}

class AdBannerPresenter: AdBannerPresenterProtocol {
    weak var view: AdBannerViewProtocol?
    private var viewName: String
    private var adService: AdServiceProtocol

    weak var delegate: AdBannerDelegate?
    private var configView: AdBannerConfigView

    var viewModel: AdBannerViewModel?

    convenience init?(
        view: AdBannerViewProtocol,
        viewName: String,
        configuration: Configuration,
        adService: AdServiceProtocol,
        viewModel: AdBannerViewModel?,
        delegate: AdBannerDelegate?
    ) {
        guard let bannerConfigView = configuration.views[viewName] as? AdBannerConfigView else {
            return nil
        }
        self.init(
            view: view,
            viewName: viewName,
            configView: bannerConfigView,
            adService: adService,
            viewModel: viewModel,
            delegate: delegate
        )
    }

    init(
        view: AdBannerViewProtocol,
        viewName: String,
        configView: AdBannerConfigView,
        adService: AdServiceProtocol,
        viewModel: AdBannerViewModel?,
        delegate: AdBannerDelegate?
    ) {
        self.view = view
        self.viewName = viewName
        self.adService = adService
        self.viewModel = viewModel
        self.configView = configView
        self.delegate = delegate
    }

    func refresh() {
        guard let viewModel = viewModel else {
            return
        }
//        let viewModel = AdBannerViewModel(
//            name: viewName,
//            configView: configView,
//            delegate: delegate
//        )
//        self.viewModel = viewModel
        view?.set(viewModel: viewModel)
        viewModel.delegate = delegate

        adService.delegate = self
        adService.request(
            blockID: configView.attributes.blockID,
            parameters: configView.attributes.parameters
        )
    }
}

extension AdBannerPresenter: AdServiceDelegate {
    func adService(_ service: AdService, didLoadWithError: Error) {
//        let viewModel = AdBannerViewModel(
//            name: viewName,
//            configView: configView,
//            delegate: delegate,
//            imageAd: nil,
//            height: CGFloat.leastNonzeroMagnitude
//        )
        if #available(iOS 11, *) {
            viewModel?.height = Float(CGFloat.leastNonzeroMagnitude)
        } else {
            viewModel?.height = 1.1
        }
        if let viewModel = viewModel {
            view?.set(viewModel: viewModel)
        }
        delegate?.heightShouldChange()
    }

    func adService(_ service: AdService, didLoadAd: YMANativeImageAd) {
        let height = YMANativeBannerView.height(
            with: didLoadAd,
            width: UIScreen.main.bounds.width,
            appearance: nil
        )

        viewModel?.imageAd = didLoadAd
        viewModel?.height = Float(height)

//        let viewModel = AdBannerViewModel(
//            name: viewName,
//            configView: configView,
//            delegate: delegate,
//            imageAd: didLoadAd,
//            height: height
//        )
//        self.viewModel = viewModel
        if let viewModel = viewModel {
            view?.set(viewModel: viewModel)
        }
        delegate?.heightShouldChange()
    }
}
