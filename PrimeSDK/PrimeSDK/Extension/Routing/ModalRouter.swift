import Foundation

public protocol ModalRouterSource: class {
    func present(controller: UIViewController)
    func present(controller: UIViewController, completion: (() -> Void)?)
}

/// Router for presenting destination on the source modally
open class ModalRouter: SourcelessRouter, Router {
    public private(set) var source: ModalRouterSource?
    public private(set) var destination: UIViewController

    public init(source: ModalRouterSource?, destination: UIViewController) {
        self.source = source
        self.destination = destination
    }

    open func route() {
        let possibleSource = topController
        if let source = source ?? possibleSource {
            self.source = source
        } else {
            self.source = window?.rootViewController
        }

        source?.present(controller: self.destination)
    }
}

// MARK: - Default implementation

extension UIViewController: ModalRouterSource {
    @objc
    public func present(controller: UIViewController) {
        self.present(controller: controller, completion: nil)
    }
    @objc
    public func present(controller: UIViewController, completion: (() -> Void)? = nil) {
        self.present(controller, animated: true, completion: completion)
    }
}
