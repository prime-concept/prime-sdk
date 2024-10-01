import UIKit

public protocol NibLoadable: class {
    static var nibName: String { get }
}

public extension NibLoadable where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}
