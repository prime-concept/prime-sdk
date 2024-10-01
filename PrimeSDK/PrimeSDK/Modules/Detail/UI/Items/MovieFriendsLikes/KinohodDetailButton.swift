import UIKit

class KinohodShadowDetailButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 4.0
        self.backgroundColor = UIColor.white
    }
}

class KinohodFlatDetailButton: UIButton {
    private let lightBackgroundTintColor = UIColor(
        red: 0,
        green: 0,
        blue: 0,
        alpha: 0.5
    )

    private let darkBackgroundTintColor = UIColor(
        red: 1,
        green: 1,
        blue: 1,
        alpha: 0.8
    )

    var isLightBackground: Bool = true {
        didSet {
            self.backgroundColor = isLightBackground ?
                UIColor.black.withAlphaComponent(0.05) : UIColor.white.withAlphaComponent(0.1)
            let buttonTint: UIColor = isLightBackground ? lightBackgroundTintColor : darkBackgroundTintColor
            if let image = image(for: .normal) {
                self.setImage(image.withRenderingMode(.alwaysTemplate).tinted(with: buttonTint), for: .normal)
            }
        }
    }

    var cornerRadius: CGFloat = 5 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5
    }
}
