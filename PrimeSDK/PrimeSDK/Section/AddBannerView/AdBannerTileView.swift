import UIKit
import YandexMobileAds

final class AdBannerTileView: BaseTileView {
    private lazy var bannerView: YMANativeBannerView = {
        let view = YMANativeBannerView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.attachEdges(to: self)
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        color = .clear
    }

    override var cornerRadius: CGFloat {
        didSet {
            bannerView.clipsToBounds = true
            bannerView.layer.cornerRadius = cornerRadius
            super.cornerRadius = cornerRadius
        }
    }

    func attach(imageAd: YMANativeImageAd) {
        bannerView.ad = imageAd
    }
}
