import UIKit

class DetailBaseButton: UIButton {
    var textColor: UIColor {
        return .white
    }
    var textFont: UIFont {
        return UIFont.font(of: 15)
    }
    var customBackgroundColor: UIColor {
        return .white
    }

    private var isInited = false

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInited {
            isInited = true
            setup()
        }
    }

    func setup() {
        tintColor = textColor
        titleLabel?.font = textFont

        semanticContentAttribute = .forceRightToLeft
        imageView?.contentMode = .scaleAspectFit
        contentHorizontalAlignment = .center

        setTitleColor(textColor, for: .normal)

        clipsToBounds = true
        layer.cornerRadius = 22
    }
}
