import UIKit

public protocol ViewReusable: class {
    static var defaultReuseIdentifier: String { get }
}

public extension ViewReusable where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

