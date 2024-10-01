import UIKit

extension UIView {
    /// Constrain 4 edges of `self` to specified `view`.
    func attachEdges(
        to view: UIView,
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) {
        NSLayoutConstraint.activate(
            [
                leftAnchor.constraint(equalTo: view.leftAnchor, constant: left),
                rightAnchor.constraint(equalTo: view.rightAnchor, constant: right),
                topAnchor.constraint(equalTo: view.topAnchor, constant: top),
                bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom)
            ]
        )
    }

    public func alignToSuperview() {
        guard let superview = self.superview else {
            return
        }

        self.attachEdges(to: superview)
    }
}
