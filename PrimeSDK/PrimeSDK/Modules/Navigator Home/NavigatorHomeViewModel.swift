import Foundation

enum HomeBlockModule {
    case view(UIView)
    case viewController(UIViewController)
}

protocol HomeContainerBlockViewModelProtocol: NavigatorHomeElementProtocol {
    func makeModule() -> HomeBlockModule?
}

class NavigatorHomeViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    private var subviewsNames: [String] = []
    var subviews: [HomeContainerBlockViewModelProtocol] {
        return subviewsNames.compactMap({ subviewForName[$0] })
    }
    var subviewForName: [String: HomeContainerBlockViewModelProtocol] = [:]


    init?(
        name: String,
        valueForAttributeID: [String: Any],
        configView: NavigatorHomeConfigView,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.viewName = name
        self.subviewsNames = configView.subviews

        for subviewName in configView.subviews {
            guard let subview = configuration.views[subviewName] else {
                continue
            }

            let subviewValueForAttributeID = NavigatorHomeViewModel.getValuesForSubview(
                valueForAttributeID: valueForAttributeID,
                subviewName: subviewName
            )

            switch subview.type {
            case "navigator-home-image":
                guard
                    let subview = subview as? NavigatorHomeImageConfigView
                else {
                    continue
                }

                let viewModel = NavigatorHomeImageViewModel(
                    name: subview.name,
                    configuration: configuration,
                    sdkManager: sdkManager
                )
                subviewForName[subview.name] = viewModel
            case "videos-horizontal-list":
                guard
                    let subview = subview as? VideosHorizontalListConfigView
                else {
                    continue
                }

                let viewModel = VideosHorizontalListViewModel(
                    name: subview.name,
                    valueForAttributeID: subviewValueForAttributeID,
                    sdkManager: sdkManager,
                    configuration: configuration
                )
                subviewForName[subview.name] = viewModel

            default:
                continue
            }
        }
    }

    func update(block: HomeContainerBlockViewModelProtocol, name: String) {
        subviewForName[name] = block
    }
}
