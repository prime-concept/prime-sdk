import UIKit

final class SectionListFlowLayout: BaseListFlowLayout {
    private var previousPaginationViewSize: CGSize?

    override var shouldInvalidateAttributesCache: Bool {
        guard let collectionView = collectionView else {
            return true
        }

        if let flowDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
            let paginationSize = flowDelegate.collectionView?(
                collectionView,
                layout: self,
                referenceSizeForFooterInSection: collectionView.numberOfSections - 1
            )

            if paginationSize != previousPaginationViewSize {
                return true
            }
        }

        return super.shouldInvalidateAttributesCache
    }

    override func prepare() {
        super.prepare()

        guard cache.isEmpty else {
            return
        }

        guard let collectionView = collectionView else {
            return
        }

        contentHeight = 0

        let xOffset = flowInset.left
        var yOffset = flowInset.top

        if let flowDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
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

        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)

                let frame = CGRect(
                    x: xOffset,
                    y: yOffset,
                    width: contentWidth,
                    height: itemHeight(forSection: item)
                )

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)

                yOffset += itemHeight(forSection: item)
            }
        }

        if let flowDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
            let paginationSize = flowDelegate.collectionView?(
                collectionView,
                layout: self,
                referenceSizeForFooterInSection: collectionView.numberOfSections - 1
            )

            let paginationSupplementaryViewAttributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                with: IndexPath(
                    item: 0,
                    section: collectionView.numberOfSections - 1
                )
            )
            paginationSupplementaryViewAttributes.frame = CGRect(
                x: 0,
                y: yOffset,
                width: paginationSize?.width ?? 0,
                height: paginationSize?.height ?? 0
            )

            if paginationSize != .zero {
                cache.append(paginationSupplementaryViewAttributes)
                yOffset += paginationSize?.height ?? 0
            }
        }

        yOffset += flowInset.bottom
        contentHeight = max(contentHeight, yOffset)
    }
}
