import UIKit

fileprivate extension CGFloat {
    static let backgroundAlpha: CGFloat = 0.65
}

final class BookingButton: DetailBaseButton {
    override var textFont: UIFont {
        return UIFont.font(of: 16, weight: .semibold)
    }
    override var customBackgroundColor: UIColor {
        return UIColor.black
    }

    func setup(with title: String?) {
        setTitle(title, for: .normal)
    }

    override func setup() {
        super.setup()

        layer.backgroundColor = customBackgroundColor
            .withAlphaComponent(.backgroundAlpha)
            .cgColor
    }
}
