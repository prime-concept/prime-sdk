import UIKit

final class HomeListFlowLayout: BaseListFlowLayout {
    override func prepare() {
        super.prepare()

        guard cache.isEmpty else {
            return
        }

        guard let collectionView = collectionView else {
            return
        }

        var yOffset: CGFloat = 0

        if let flowDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
           collectionView.numberOfSections > 0 {
            let headerSize = flowDelegate.collectionView?(
                collectionView,
                layout: self,
                referenceSizeForHeaderInSection: 0
            ) ?? .zero

            let headerSupplementaryViewAttributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                with: IndexPath(
                    item: 0,
                    section: 0
                )
            )

            headerSupplementaryViewAttributes.frame = CGRect(
                x: 0,
                y: yOffset,
                width: headerSize.width,
                height: headerSize.height
            )

            if headerSize != .zero {
                cache.append(headerSupplementaryViewAttributes)
                yOffset += headerSize.height
            }
        }

        yOffset += flowInset.top

        for section in 0..<collectionView.numberOfSections {
            let itemsInSection = collectionView.numberOfItems(inSection: section)

            var xOffset = flowInset.left
            for item in 0..<itemsInSection {
                let indexPath = IndexPath(item: item, section: section)

                let itemWidth = sectionWidth(itemsCount: itemsInSection)
                let frame = CGRect(
                    x: xOffset,
                    y: yOffset,
                    width: itemWidth,
                    height: itemHeight(forSection: section)
                )

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)

                xOffset += itemWidth
            }

            yOffset += itemHeight(forSection: section)
        }
        yOffset += flowInset.bottom
        contentHeight = max(contentHeight, yOffset)
    }

    private func sectionWidth(itemsCount: Int) -> CGFloat {
        return contentWidth / CGFloat(itemsCount)
    }
}
