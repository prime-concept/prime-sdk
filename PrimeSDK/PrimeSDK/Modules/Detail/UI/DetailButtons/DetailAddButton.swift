import UIKit

final class DetailAddButton: UIView {
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
    var onAdd: (() -> Void)? {
        didSet {
            view.onClick = onAdd
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
        view.setImage(UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        view.setImage(UIImage(named: "saved")?.withRenderingMode(.alwaysTemplate), for: .selected)

        view.setTitle("AddToFavorites", for: .normal)
        view.setTitle("AddedToFavorites", for: .selected)

        view.isSelected = isSelected
        view.textColor = textColor
        view.textFont = textFont
        view.customBackgroundColor = customBackgroundColor

        view.onClick = onAdd
    }
}
