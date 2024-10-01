import Foundation
import SwiftyJSON

protocol ListItemViewModelProtocol: ViewModelProtocol, ListItemConfigConstructible {
    func makeCell(
        for collectionView: UICollectionView,
        indexPath: IndexPath,
        listState: ListViewState
    ) -> UICollectionViewCell
}

class ListViewModel: ViewModelProtocol {
    var viewName: String = ""

    var itemWidth: CGFloat = 0
    var itemHeight: CGFloat = 0
    var data: [ListItemViewModelProtocol] = []

    var header: ListHeaderViewModel?

    init(header: ListHeaderViewModel?, data: [ListItemViewModelProtocol], size: CGSize) {
        self.header = header
        self.data = data
        self.itemWidth = size.width
        self.itemHeight = size.height
    }

    class var empty: ListViewModel {
        return empty(size: CGSize.zero)
    }

    class func empty(size: CGSize) -> ListViewModel {
        return ListViewModel(header: nil, data: [], size: size)
    }

    //TODO: Make failable init - could not parse view
    convenience init(
        name: String,
        jsonValueForAttributeID: [String: JSON],
        defaultAttributes: ListConfigView.Attributes? = nil
    ) {
        self.init(name: name, attributes: defaultAttributes)
    }

    init(name: String, attributes: ListConfigView.Attributes?) {
        guard attributes != nil else {
            return
        }
        self.viewName = name
    }

    var attributes: [String: Any] {
        let screenScale = UIScreen.main.scale
        return [
            "item_width": Int(itemWidth * screenScale),
            "item_height": Int(itemHeight * screenScale)
        ]
    }
}
