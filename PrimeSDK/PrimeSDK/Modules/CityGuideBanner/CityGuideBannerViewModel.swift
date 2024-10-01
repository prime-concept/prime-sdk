import Foundation

final class CityGuideBannerViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] = [:]

    var height: Float
    var headers: [String: String] = [:]
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
        defaultAttributes: CityGuideBannerConfigView.Attributes,
        sdkManager: PrimeSDKManagerProtocol? = nil,
        configuration: Configuration? = nil
    ) {
        self.viewName = name
        self.sdkManager = sdkManager
        self.configuration = configuration

        self.height = defaultAttributes.height

        guard
            !defaultAttributes.citiesConfig.isEmpty || !defaultAttributes.defaultConfig.isEmpty,
            let cityID = sdkManager?.changeCityDelegate?.getSelectedCityID()
        else {
            return nil
        }

        guard var config = defaultAttributes.citiesConfig[cityID] else {
            return nil
        }

        config = config.isEmpty
            ? defaultAttributes.defaultConfig
            : config

        self.contentURL = config.contentURL
        self.imageURL = config.imageURL
        self.headers = config.headers
    }

    var configuration: Configuration?
    var sdkManager: PrimeSDKManagerProtocol?
}

extension CityGuideBannerViewModel: HomeContainerBlockViewModelProtocol {
    func makeModule() -> HomeBlockModule? {
        guard let sdkManager = self.sdkManager else {
            return nil
        }

        let view = CityGuideBannerView(
            viewName: self.viewName,
            sdkManager: sdkManager,
            viewModel: self
        )

        return .view(view)
    }
}
