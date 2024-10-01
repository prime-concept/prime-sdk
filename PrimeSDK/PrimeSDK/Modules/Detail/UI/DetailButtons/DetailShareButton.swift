import UIKit

class DetailShareButton: UIView {
    private let textColor: UIColor = .black
    private let textFont = UIFont.font(of: 12, weight: .semibold)
    private let customBackgroundColor = UIColor(
        red: 0.95,
        green: 0.95,
        blue: 0.95,
        alpha: 1
    )

    var isSelected: Bool = false {
        didSet {
            view.isSelected = isSelected
        }
    }
    var onShare: (() -> Void)? {
        didSet {
            view.onClick = onShare
        }
    }

    lazy var view: CustomButton = .fromNib()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.attachEdges(to: self)

        setupAppearance()
    }

    private func setupAppearance() {
        view.setImage(UIImage(named: "share")?.withRenderingMode(.alwaysTemplate), for: .normal)

        view.setTitle("Share", for: .normal)

        view.isSelected = isSelected
        view.textColor = textColor
        view.textFont = textFont
        view.customBackgroundColor = customBackgroundColor

        view.onClick = onShare
    }
}
