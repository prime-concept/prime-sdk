import Foundation
import UIKit

enum NavigatorHomeElementWidth: String {
    case full, half
}

protocol NavigatorHomeElementProtocol {
    var width: NavigatorHomeElementWidth { get }
}

extension NavigatorHomeElementProtocol {
    var width: NavigatorHomeElementWidth {
        return .full
    }
}

class NavigatorHomeImageViewModel: ViewModelProtocol, NavigatorHomeElementProtocol {
    var viewName: String = ""

    private let parsingService = ParsingService()

    var attributes: [String: Any] {
        return [:]
    }

    var height: Float
    var imagePath: String
    var imageURL: URL? {
        return URL(string: imagePath)
    }

    var width: NavigatorHomeElementWidth
    var title: String

    init?(
        name: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        guard let configView = configuration.views[name] as? NavigatorHomeImageConfigView else {
            return nil
        }
        self.viewName = name
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.height = configView.attributes.height
        self.width = NavigatorHomeElementWidth(rawValue: configView.attributes.width) ?? .full
        self.imagePath = parsingService.process(
            string: configView.attributes.image,
            action: "",
            viewModel: nil
        ) as? String ?? ""
        self.title = configView.attributes.title
    }

    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol
}

extension NavigatorHomeImageViewModel: HomeContainerBlockViewModelProtocol {
    func makeViewController() -> UIViewController {
        let assembly = NavigatorHomeImageAssembly(
            name: viewName,
            configuration: configuration,
            sdkManager: self.sdkManager
        )
        return assembly.make()
    }

    func makeModule() -> HomeBlockModule? {
        return .viewController(makeViewController())
    }
}
