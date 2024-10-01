import FloatingPanel
import Foundation

enum KinohodTicketsBookerModuleSource: Equatable {
    case movie(id: String)
    case cinema(id: String)

    var movieID: String? {
        switch self {
        case .movie(let id):
            return id
        default:
            return nil
        }
    }

    var cinemaID: String? {
        switch self {
        case .cinema(let id):
            return id
        default:
            return nil
        }
    }
}

final class KinohodTicketsBookerAssembly {
    var name: String
    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol
    var moduleSource: KinohodTicketsBookerModuleSource
    var shouldConstrainHeight: Bool

    init(
        name: String,
        moduleSource: KinohodTicketsBookerModuleSource,
        shouldConstrainHeight: Bool,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.name = name
        self.moduleSource = moduleSource
        self.shouldConstrainHeight = shouldConstrainHeight
        self.configuration = configuration
        self.sdkManager = sdkManager
    }

    func make() -> UIViewController {
        let controller = KinohodTicketsBookerViewController()
        let presenter = KinohodTicketsBookerPresenter(
            view: controller,
            viewName: self.name,
            moduleSource: self.moduleSource,
            shouldConstrainHeight: self.shouldConstrainHeight,
            configuration: self.configuration,
            apiService: APIService(sdkManager: sdkManager),
            locationService: LocationService(),
            sdkManager: self.sdkManager
        )
        controller.presenter = presenter
        return controller
    }
}
