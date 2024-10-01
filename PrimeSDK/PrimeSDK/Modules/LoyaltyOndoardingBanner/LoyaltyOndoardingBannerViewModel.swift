import Foundation

final class LoyaltyOnboardingBannerViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] = [:]

    var height: Float = 130
    var contentURL: String
    var imageURL: String

    var imageURLValue: URL {
        if let url = URL(string: self.imageURL) {
            return url
        } else {
            fatalError("Image URL must exists")
        }
    }

    var contentURLValue: URL {
        if let url = URL(string: self.contentURL) {
            return url
        } else {
            fatalError("Content URL must exists")
        }
    }

    init?(
        name: String,
        defaultAttributes: LoyaltyOnboardingBannerConfigView.Attributes,
        sdkManager: PrimeSDKManagerProtocol? = nil,
        configuration: Configuration? = nil
    ) {
        self.viewName = name
        self.sdkManager = sdkManager
        self.configuration = configuration

        self.height = defaultAttributes.height

        self.contentURL = defaultAttributes.contentURL
        self.imageURL = defaultAttributes.imageURL
    }

    var configuration: Configuration?
    var sdkManager: PrimeSDKManagerProtocol?
}

extension LoyaltyOnboardingBannerViewModel: HomeContainerBlockViewModelProtocol {
    func makeModule() -> HomeBlockModule? {
        guard let sdkManager = self.sdkManager else {
            return nil
        }

        let view = LoyaltyOnboardingBannerView(
            viewName: self.viewName,
            sdkManager: sdkManager,
            viewModel: self
        )

        return .view(view)
    }
}
