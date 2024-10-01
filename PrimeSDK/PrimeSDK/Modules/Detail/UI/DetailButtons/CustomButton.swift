import UIKit

final class FakeOverlayButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = UIColor.white.withAlphaComponent(0.35)
            } else {
                backgroundColor = .clear
            }
        }
    }
}

class CustomButton: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!

    private var isInited: Bool = false
    private var button = UIButton(type: .system)

    var onClick: (() -> Void)?

    var textColor: UIColor = .white {
        didSet {
            titleLabel.textColor = textColor
        }
    }
    var textFont = UIFont.font(of: 15) {
        didSet {
            titleLabel.font = textFont
        }
    }
    var customBackgroundColor: UIColor = .white {
        didSet {
            layer.backgroundColor = customBackgroundColor.cgColor
        }
    }

    var defaultTintColor: UIColor {
        return .black
    }

    var customTintColor: UIColor = .black {
        didSet {
            tintColor = customTintColor
        }
    }

    var isSelected: Bool = false {
        didSet {
            button.isSelected = isSelected
            updateAppearance()
        }
    }

    var cornerRadius: CGFloat = 22 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupAppearance()
    }

    private func setupAppearance() {
        layer.cornerRadius = cornerRadius
        tintColor = customTintColor
    }

    private func updateAppearance() {
        titleLabel.text = button.title(for: button.state)
        imageView.image = button.image(for: button.state)
        tintColor = button.isSelected ? defaultTintColor : customTintColor
    }

    func setTitle(_ title: String?, for state: UIControl.State) {
        button.setTitle(title, for: state)
    }

    func setImage(_ image: UIImage?, for state: UIControl.State) {
        button.setImage(image, for: state)
    }

    @IBAction func onButtonClick(_ sender: Any) {
        onClick?()
        updateAppearance()
    }
}
