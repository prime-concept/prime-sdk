import UIKit

public extension UIView {
    func dropShadowForView() {
        layer.shadowOffset = CGSize(width: -1, height: 2)
        layer.shadowRadius = 6.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
