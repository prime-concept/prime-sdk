import Foundation

public extension UIFont {
    static func font(of size: CGFloat, weight: Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
