import UIKit

public extension UIView {
    class func fromNib<T: UIView>(nibName: String) -> T {
        let bundle = Bundle(for: T.self)
        return bundle.loadNibNamed(
            nibName,
            owner: nil,
            options: nil
        // swiftlint:disable:next force_cast
        )?.first as! T
    }

    class func fromNib<T: UIView>() -> T {
        return fromNib(nibName: String(describing: T.self))
    }
}
