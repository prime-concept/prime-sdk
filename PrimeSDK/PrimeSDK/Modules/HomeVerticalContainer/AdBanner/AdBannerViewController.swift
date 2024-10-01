import UIKit

class AdBannerViewController: UIViewController, AdBannerViewProtocol {
    @IBOutlet weak var adBannerTileView: AdBannerTileView!
    @IBOutlet weak var bannerHeightConstraint: NSLayoutConstraint!

    var presenter: AdBannerPresenterProtocol?

    convenience init() {
        self.init(nibName: "AdBannerViewController", bundle: .primeSdk)
    }

    func set(viewModel: AdBannerViewModel) {
        if let imageAd = viewModel.imageAd {
            adBannerTileView.attach(imageAd: imageAd)
        }
        bannerHeightConstraint.constant = CGFloat(viewModel.height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.refresh()
    }
}

