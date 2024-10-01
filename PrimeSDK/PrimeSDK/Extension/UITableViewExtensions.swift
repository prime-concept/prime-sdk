import UIKit

public extension UITableView {
    func register<T: UITableViewCell>(cellClass: T.Type) where T: ViewReusable {
        self.register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }

    func register<T: UIView>(headerFooterViewClass: T.Type) where T: ViewReusable {
        self.register(T.self, forHeaderFooterViewReuseIdentifier: T.defaultReuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ViewReusable {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }

        return cell
    }

    func dequeueReusableHeaderFooterView<T: UIView>() -> T where T: ViewReusable {
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: T.defaultReuseIdentifier) as? T else {
            fatalError("Could not dequeue header/footer view with identifier: \(T.defaultReuseIdentifier)")
        }

        return view
    }

    func register<T: UITableViewCell>(cellClass: T.Type) where T: ViewReusable, T: NibLoadable {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)

        self.register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
}

