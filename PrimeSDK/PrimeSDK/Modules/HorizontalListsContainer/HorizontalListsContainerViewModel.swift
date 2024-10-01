import Foundation

struct HorizontalListsContainerViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    private var subviewsNames: [String] = []
    var subviews: [DetailHorizontalItemsViewModel] {
        return subviewsNames.compactMap({ subviewForName[$0] })
    }
    var subviewForName: [String: DetailHorizontalItemsViewModel] = [:]

    init() {}

    init(
        name: String,
        valueForAttributeID: [String: Any],
        configView: HorizontalListsContainerConfigView,
        otherConfigViews: [String: ConfigView],
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.viewName = name
        self.subviewsNames = configView.subviews

        for subviewName in configView.subviews {
            guard let subview = otherConfigViews[subviewName] else {
                continue
            }
            guard
                let detailHorizontalList = subview as? DetailHorizontalListConfigView,
                let itemView = otherConfigViews[detailHorizontalList.item] as? ListItemConfigView
            else {
                continue
            }

            if let viewModel = try? DetailHorizontalItemsViewModel(
                viewName: subviewName,
                valueForAttributeID: [:],
                listConfigView: detailHorizontalList,
                itemView: itemView,
                getDistanceBlock: nil,
                sdkManager: sdkManager,
                configuration: configuration
            ) {
                subviewForName[subview.name] = viewModel
            }
        }
    }

    mutating func update(block: DetailHorizontalItemsViewModel, name: String) {
        subviewForName[name] = block
    }
}
