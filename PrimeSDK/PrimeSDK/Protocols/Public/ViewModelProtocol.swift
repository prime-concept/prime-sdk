import Foundation

public protocol ViewModelProtocol: SubviewContainerViewModelProtocol {
    var viewName: String { get set }

    var attributes: [String: Any] { get }
}

public protocol SubviewContainerViewModelProtocol {
    static func getValuesForSubview(valueForAttributeID: [String: Any], subviewName: String) -> [String: Any]
}

extension SubviewContainerViewModelProtocol {
    public static func getValuesForSubview(valueForAttributeID: [String: Any], subviewName: String) -> [String: Any] {
        let filteredDict = valueForAttributeID.filter {
            $0.key.range(of: subviewName)?.lowerBound == $0.key.startIndex
        }
        let valuesForSubview = filteredDict.compactMap { (record) -> (String, Any)? in
            if let keyRange = record.key.range(of: "\(subviewName).") {
                var mutableKey = record.key
                mutableKey.removeSubrange(keyRange)
                return (mutableKey, record.value)
            }
            return nil
        }
        let subviewValueForAttributeID: [String: Any] = Dictionary(uniqueKeysWithValues: valuesForSubview)
        return subviewValueForAttributeID
    }
}

protocol ListViewModelProtocol {
    associatedtype ItemType

    func initItems(
        valueForAttributeID: [String: Any],
        listName: String,
        initBlock: (([String: Any], Int) -> ItemType?)
    ) -> [ItemType]
}

extension ListViewModelProtocol {
    func initItems(
        valueForAttributeID: [String: Any],
        listName: String,
        initBlock: (([String: Any], Int) -> ItemType?)
    ) -> [ItemType] {
        let valuesForItemType = valueForAttributeID.filter {
            $0.key.range(of: listName)?.lowerBound == $0.key.startIndex
        }

        let count = valuesForItemType.keys.reduce(0) { (curCount, key) -> Int in
            let tokens = key.components(separatedBy: ".")
            if tokens.count >= 2 {
                if let index = Int(tokens[1]) {
                    return max(curCount, index + 1)
                }
            }
            return curCount
        }

        var items: [ItemType] = []
        for itemIndex in 0 ..< count {
            let valuesForCell = valuesForItemType.compactMap { (record) -> (String, Any)? in
                if var keyRange = record.key.range(of: "\(listName).\(itemIndex)") {
                    if record.key.endIndex != keyRange.upperBound && record.key[keyRange.upperBound] == "." {
                        keyRange = keyRange.lowerBound..<record.key.index(after: keyRange.upperBound)
                    }
                    var mutableKey = record.key
                    mutableKey.removeSubrange(keyRange)
                    return (mutableKey, record.value)
                }
                return nil
            }
            let dict: [String: Any] = Dictionary(uniqueKeysWithValues: valuesForCell)
            if let viewModel = initBlock(dict, itemIndex) {
                items += [viewModel]
            }
        }
        return items
    }
}

protocol SectionCardListViewModelProtocol: ListViewModelProtocol where ItemType == ListItemViewModel {
    func getItems(
        valueForAttributeID: [String: Any],
        itemView: ListItemConfigView,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)?,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) -> [ListItemViewModel]
}

extension SectionCardListViewModelProtocol {
    func getItems(
        valueForAttributeID: [String: Any],
        itemView: ListItemConfigView,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)?,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) -> [ListItemViewModel] {
        return initItems(
            valueForAttributeID: valueForAttributeID,
            listName: itemView.name,
            initBlock: { valueForAttributeID, position in
                ListItemViewModel(
                    name: itemView.name,
                    valueForAttributeID: valueForAttributeID,
                    defaultAttributes: itemView.attributes,
                    position: position,
                    getDistanceBlock: getDistanceBlock,
                    sdkManager: sdkManager,
                    configuration: configuration
                )
            }
        )
    }
}
