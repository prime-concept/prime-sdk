import UIKit

class VerticalInsetView: UIView, NibLoadable {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    var inset: CGFloat = .leastNonzeroMagnitude {
        didSet {
            heightConstraint.constant = inset
        }
    }

    var config: HomeHeaderButtonViewConfig? {
        didSet {
            addButton()
        }
    }
    var onButtonTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        if #available(iOS 11, *) {
            inset = .leastNonzeroMagnitude
        } else {
            inset = 1.1
        }
    }

    private func addButton() {
        guard
            inset > 0,
            let config = config,
            !config.title.isEmpty
        else {
            return
        }

        let button = HomeHeaderButtonView()
        addSubview(button)
        button.config = config
        button.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview()
        }

        button.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didButtonTap)
            )
        )
    }

    @objc
    private func didButtonTap() {
        onButtonTap?()
    }
}
