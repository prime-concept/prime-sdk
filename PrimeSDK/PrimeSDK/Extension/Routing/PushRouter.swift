import UIKit

public protocol PushRouterSource: class {
    func push(controller: UIViewController)
}

/// Router for presenting destination on the source's navigation controller
open class PushRouter: Router {
    public private(set) var source: PushRouterSource
    public private(set) var destination: UIViewController

    public init(source: PushRouterSource, destination: UIViewController) {
        self.source = source
        self.destination = destination
    }

    open func route() {
        self.source.push(controller: self.destination)
    }
}

// MARK: - Default implementation

extension UIViewController: PushRouterSource {
    @objc
    public func push(controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

