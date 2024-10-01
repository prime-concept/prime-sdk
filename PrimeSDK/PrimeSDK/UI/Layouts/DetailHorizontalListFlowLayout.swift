import UIKit

final class DetailHorizontalListFlowLayout: BaseListFlowLayout {
    override var flowInset: UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 7.5, bottom: 0.0, right: 7.5)
    }

    override var contentWidth: CGFloat {
        return _contentWidth
    }

    private var _contentWidth = CGFloat(0)

    private var overlapDelta: CGFloat {
        return itemType.overlapDelta
    }
    private var itemHeight: CGFloat {
        return itemType.itemHeight
    }
    private var itemWidth: CGFloat {
        return itemType.itemWidth
    }

    var itemType: ItemSizeType

    required  init(itemSizeType: ItemSizeType) {
        self.itemType = itemSizeType
        super.init(itemSizeType: itemSizeType)
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        guard cache.isEmpty else {
            return
        }

        guard let collectionView = collectionView else {
            return
        }

        var yOffset = flowInset.top
        var xOffset = CGFloat(0)

        for section in 0..<collectionView.numberOfSections {
            xOffset = flowInset.left
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)

                let frame = CGRect(
                    x: xOffset,
                    y: yOffset,
                    width: itemWidth,
                    height: itemHeight
                )

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)

                xOffset += itemWidth + overlapDelta
            }

            yOffset += itemHeight
            xOffset += flowInset.right - overlapDelta
        }

        yOffset += flowInset.bottom

        contentHeight = max(contentHeight, yOffset)
        _contentWidth = max(_contentWidth, xOffset)
    }
}
