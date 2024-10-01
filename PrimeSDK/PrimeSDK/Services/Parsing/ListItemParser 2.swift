import Foundation

class ListItemParser<ItemType> {
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
