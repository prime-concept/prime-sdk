import Foundation
import YandexMobileAds

protocol AdServiceDelegate: class {
    func adService(_ service: AdService, didLoadAd: YMANativeImageAd)
    func adService(_ service: AdService, didLoadWithError: Error)
}

protocol AdServiceProtocol: class {
    var delegate: AdServiceDelegate? { get set }

    func request(blockID: String, parameters: [String: String])
}
// swiftlint:disable implicitly_unwrapped_optional
final class AdService: NSObject, AdServiceProtocol {
    public weak var delegate: AdServiceDelegate?

    var adLoader: YMANativeAdLoader?
    var sdkManager: PrimeSDKManagerProtocol

    public init(sdkManager: PrimeSDKManagerProtocol) {
        self.sdkManager = sdkManager
        super.init()
    }

    public func request(blockID: String, parameters: [String: String]) {
        let configuration = YMANativeAdLoaderConfiguration(
            blockID: blockID,
            loadImagesAutomatically: true
        )
        adLoader = YMANativeAdLoader(configuration: configuration)
        self.adLoader?.delegate = self

        var location: CLLocation?
        if let coordinate = sdkManager.listDelegate?.getCityCoordinate() {
            location = CLLocation(geoCoordinates: coordinate)
        }

        let adRequest = YMAAdRequest(
            location: location,
            contextQuery: nil,
            contextTags: nil,
            parameters: parameters
        )

        adLoader?.loadAd(with: adRequest)
    }
}

extension AdService: YMANativeAdLoaderDelegate {
    // swiftlint:disable:next identifier_name
    func nativeAdLoader(_ loader: YMANativeAdLoader!, didLoad ad: YMANativeImageAd) {
        delegate?.adService(self, didLoadAd: ad)
    }

    func nativeAdLoader(_ loader: YMANativeAdLoader!, didFailLoadingWithError error: Error) {
        print("ad service error: \(error)")
        delegate?.adService(self, didLoadWithError: error)
    }
}
// swiftlint:enable implicitly_unwrapped_optional
