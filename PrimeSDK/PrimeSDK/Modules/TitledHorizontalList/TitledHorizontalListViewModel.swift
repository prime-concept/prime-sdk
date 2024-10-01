import Foundation

class TitledHorizontalListViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        let screenScale = UIScreen.main.scale
        return [
            "item_width": Int(CGFloat(itemWidth) * screenScale),
            "item_height": Int(CGFloat(itemHeight) * screenScale)
        ]
    }

    let itemHeight: Float
    let itemWidth: Float
    let spacing: Float
    let sideInsets: Float

    let title: String?
    let id: String?
    var count: Int?
    var items: [TitledHorizontalListCardViewModelProtocol] = []
    var genres: [String] = []
    let showTitle: Bool
    let showAll: Bool
    var shouldHideAll = false
    var titleColor = UIColor.black
    var allColor = UIColor(hex: 0x0080ff)
    var getDistanceBlock: ((GeoCoordinate?) -> Double?)?

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: TitledHorizontalListConfigView.Attributes,
        itemView: ConfigView,
        sdkManager: PrimeSDKManagerProtocol? = nil,
        configuration: Configuration? = nil,
        shouldHideAll: Bool,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)? = nil
    ) {
        self.viewName = name
        self.itemHeight = valueForAttributeID["item_height"] as? Float ?? defaultAttributes.itemHeight
        self.itemWidth = valueForAttributeID["item_width"] as? Float ?? defaultAttributes.itemWidth
        self.spacing = valueForAttributeID["spacing"] as? Float ?? defaultAttributes.spacing
        self.sideInsets = valueForAttributeID["side_insets"] as? Float ?? defaultAttributes.sideInsets
        self.title = valueForAttributeID["title"] as? String ?? defaultAttributes.title
        self.id = valueForAttributeID["id"] as? String
        self.showTitle = valueForAttributeID["show_title"] as? Bool ?? defaultAttributes.showTitle
        self.showAll = valueForAttributeID["show_all"] as? Bool ?? defaultAttributes.showAll
        self.titleColor = UIColor(
            hex: valueForAttributeID["title_color"] as? String ?? defaultAttributes.titleColor
        ) ?? self.titleColor
        self.allColor = UIColor(
            hex: valueForAttributeID["all_color"] as? String ?? defaultAttributes.allColor
        ) ?? self.allColor

        self.sdkManager = sdkManager
        self.configuration = configuration
        self.shouldHideAll = shouldHideAll
        self.getDistanceBlock = getDistanceBlock
        self.items = getItems(valueForAttributeID: valueForAttributeID, itemView: itemView)
    }

    var configuration: Configuration?
    var sdkManager: PrimeSDKManagerProtocol?

    var isDummy: Bool {
        return items.first?.title == "Loading"
    }

    var shouldShowAllButton: Bool {
        !self.shouldHideAll && self.showAll
    }
}

extension TitledHorizontalListViewModel: HomeContainerBlockViewModelProtocol {
    func makeModule() -> HomeBlockModule? {
        guard let configuration = configuration, let sdkManager = sdkManager else {
            return nil
        }

        let assembly = TitledHorizontalListAssembly(
            name: viewName,
            configuration: configuration,
            sdkManager: sdkManager,
            shouldHideAll: shouldHideAll
        )
        let viewController = assembly.make()

        return .viewController(viewController)
    }
}

extension TitledHorizontalListViewModel: ListViewModelProtocol {
    typealias ItemType = TitledHorizontalListCardViewModelProtocol

    func getItems<T: ConfigView>(
        valueForAttributeID: [String: Any],
        itemView: T
    ) -> [TitledHorizontalListCardViewModelProtocol] {
        print("item view: \(itemView)")
        if let itemView = itemView as? FlatMovieCardConfigView {
            return initItems(
                valueForAttributeID: valueForAttributeID,
                listName: itemView.name,
                initBlock: { itemValueForAttrubuteID, _ in
                    HomeMoviePlainCardViewModel(
                        name: itemView.name,
                        valueForAttributeID: itemValueForAttrubuteID,
                        defaultAttributes: itemView.attributes
                    )
                }
            )
        }
        if let itemView = itemView as? HomeSelectionCardConfigView {
            return initItems(
                valueForAttributeID: valueForAttributeID,
                listName: itemView.name,
                initBlock: { itemValueForAttrubuteID, _ in
                    HomeSelectionCardViewModel(
                        name: itemView.name,
                        valueForAttributeID: itemValueForAttrubuteID,
                        defaultAttributes: itemView.attributes
                    )
                }
            )
        }
        if let itemView = itemView as? ListItemConfigView {
            guard let sdkManager = self.sdkManager, let configuration = self.configuration else {
                return []
            }
            return initItems(
                valueForAttributeID: valueForAttributeID,
                listName: itemView.name,
                initBlock: { itemValueForAttrubuteID, _ in
                    ListItemViewModel(
                        name: itemView.name,
                        valueForAttributeID: itemValueForAttrubuteID,
                        defaultAttributes: itemView.attributes,
                        getDistanceBlock: self.getDistanceBlock,
                        sdkManager: sdkManager,
                        configuration: configuration
                    )
                }
            )
        }
        return []
    }
}
