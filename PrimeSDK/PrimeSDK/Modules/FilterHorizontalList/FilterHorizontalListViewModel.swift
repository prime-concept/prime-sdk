import Foundation

class FilterHorizontalListViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        let screenScale = UIScreen.main.scale
        return [
            "item_height": Int(CGFloat(itemHeight) * screenScale)
        ]
    }

    let itemHeight: Float
    let spacing: Float
    var items: [FilterItemViewModel] = []
    let title: String?
    let showTitle: Bool

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: FilterHorizontalListConfigView.Attributes,
        configView: FilterHorizontalListConfigView,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.viewName = name
        self.itemHeight = valueForAttributeID["item_height"] as? Float ?? defaultAttributes.itemHeight
        self.spacing = valueForAttributeID["spacing"] as? Float ?? defaultAttributes.spacing
        self.title = valueForAttributeID["title"] as? String ?? defaultAttributes.title
        self.showTitle = valueForAttributeID["show_title"] as? Bool ?? defaultAttributes.showTitle

        self.sdkManager = sdkManager
        self.configuration = configuration

        for subview in configView.subviews {
            if let itemConfigView = configuration.views[subview] as? FilterItemConfigView {
                let viewModel = FilterItemViewModel(
                    name: itemConfigView.name,
                    valueForAttributeID: [:],
                    defaultAttributes: itemConfigView.attributes
                )
                items.append(viewModel)
            }
        }
    }

    var configuration: Configuration?
    var sdkManager: PrimeSDKManagerProtocol?
}

extension FilterHorizontalListViewModel: HomeContainerBlockViewModelProtocol {
    func makeModule() -> HomeBlockModule? {
        guard let configuration = configuration, let sdkManager = sdkManager else {
            return nil
        }

        let assembly = FilterHorizontalListAssembly(
            name: viewName,
            configuration: configuration,
            sdkManager: sdkManager,
            viewModel: self
        )
        let viewController = assembly.make()

        return .viewController(viewController)
    }
}
