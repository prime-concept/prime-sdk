import UIKit

public extension UICollectionView {
    func register<T: UICollectionViewCell>(cellClass: T.Type) where T: ViewReusable {
        self.register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }

    func register<T: UICollectionReusableView>(
        viewClass: T.Type,
        forSupplementaryViewOfKind kind: String
    ) where T: ViewReusable {
        self.register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.defaultReuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ViewReusable {
        guard let cell = self.dequeueReusableCell(
            withReuseIdentifier: T.defaultReuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }

        return cell
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        ofKind kind: String,
        for indexPath: IndexPath
    ) -> T where T: ViewReusable {
        guard let view = self.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: T.defaultReuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError(
                "Could not dequeue supplementary view" +
                "with identifier: \(T.defaultReuseIdentifier)"
            )
        }

        return view
    }

    // MARK: - NibLoadable

    func register<T: UICollectionViewCell>(cellClass: T.Type) where T: ViewReusable, T: NibLoadable {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)

        self.register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }

    func register<T: UICollectionReusableView>(
        viewClass: T.Type,
        forSupplementaryViewOfKind kind: String
    ) where T: ViewReusable, T: NibLoadable {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)

        self.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.defaultReuseIdentifier)
    }
}

