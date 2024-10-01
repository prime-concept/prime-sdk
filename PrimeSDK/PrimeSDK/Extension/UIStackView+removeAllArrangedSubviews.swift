import UIKit

public extension UIStackView {
    func removeAllArrangedSubviews() {
        self.subviews.forEach { subview in
            self.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
}
