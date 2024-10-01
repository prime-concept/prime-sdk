import Foundation

class MoviesPopularityChartViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        let screenScale = UIScreen.main.scale
        return [
            "item_height": Int(CGFloat(itemHeight) * screenScale)
        ]
    }

    let spacing: Float = 5
    let itemHeight: Float
    var itemWidth: Float {
        Float(UIScreen.main.bounds.width) - 16
    }
    var viewHeight: Float {
        (itemHeight + spacing) * Float(items.count)
    }

    let title: String?
    let id: String?
    var items: [MoviesPopularityChartItemViewModel] = []
    var genres: [String] = []
    let showTitle: Bool

    var countLookedTotal: Int {
        items.map { $0.countLooked }.reduce(0, +)
    }

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: MoviesPopularityChartConfigView.Attributes,
        itemView: PopularityChartRowConfigView,
        sdkManager: PrimeSDKManagerProtocol? = nil,
        configuration: Configuration? = nil
    ) {
        self.viewName = name
        self.itemHeight = valueForAttributeID["item_height"] as? Float ?? defaultAttributes.itemHeight
        self.title = valueForAttributeID["title"] as? String ?? defaultAttributes.title
        self.id = valueForAttributeID["id"] as? String
        self.showTitle = valueForAttributeID["show_title"] as? Bool ?? defaultAttributes.showTitle

        self.sdkManager = sdkManager
        self.configuration = configuration

        self.items = getItems(
            valueForAttributeID: valueForAttributeID,
            itemView: itemView
        ).sorted {
            $0.countLooked > $1.countLooked
        }
        self.items = Array(self.items.prefix(5))

        for i in 0..<items.count {
            items[i].countLookedTotal = self.countLookedTotal
        }
    }

    var configuration: Configuration?
    var sdkManager: PrimeSDKManagerProtocol?

    var isDummy: Bool {
        return items.first?.title == "Loading"
    }
}

extension MoviesPopularityChartViewModel: HomeContainerBlockViewModelProtocol {
    func makeModule() -> HomeBlockModule? {
        guard let configuration = configuration, let sdkManager = sdkManager else {
            return nil
        }

        let assembly = MoviesPopularityChartAssembly(
            name: viewName,
            configuration: configuration,
            sdkManager: sdkManager,
            viewModel: self
        )
        let viewController = assembly.make()

        return .viewController(viewController)
    }
}

extension MoviesPopularityChartViewModel: ListViewModelProtocol {
    typealias ItemType = MoviesPopularityChartItemViewModel

    func getItems(
        valueForAttributeID: [String: Any],
        itemView: PopularityChartRowConfigView
    ) -> [MoviesPopularityChartItemViewModel] {
        return initItems(
            valueForAttributeID: valueForAttributeID,
            listName: itemView.name,
            initBlock: { itemValueForAttrubuteID, _ in
                MoviesPopularityChartItemViewModel(
                    name: itemView.name,
                    valueForAttributeID: itemValueForAttrubuteID,
                    defaultAttributes: itemView.attributes
                )
            }
        )
    }
}
