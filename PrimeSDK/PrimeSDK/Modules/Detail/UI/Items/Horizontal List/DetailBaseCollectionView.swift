import UIKit

class DetailBaseCollectionView: UIView {
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!

    private var previousCollectionViewHeight = CGFloat(0)
    private var previousCollectionViewWidth = CGFloat(0)

    var onLayoutUpdate: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()

        if previousCollectionViewWidth != bounds.width {
            collectionView.collectionViewLayout.invalidateLayout()
//            previousCollectionViewWidth = bounds.width

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                let newHeight = strongSelf
                    .collectionView
                    .collectionViewLayout
                    .collectionViewContentSize
                    .height

                if strongSelf.previousCollectionViewHeight != newHeight {
                    strongSelf.previousCollectionViewHeight = newHeight

                    strongSelf.heightConstraint.constant = newHeight
                    strongSelf.onLayoutUpdate?()
                }
            }
        }
    }
}
