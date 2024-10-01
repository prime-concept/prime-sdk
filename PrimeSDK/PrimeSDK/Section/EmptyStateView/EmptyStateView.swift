import UIKit

class EmptyStateView: UIView, NibLoadable {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!

    var retryAction: (() -> Void)?

    override func awakeFromNib() {
        self.imageView.image = UIImage(named: "icon_search", in: .primeSdk, compatibleWith: nil)
        self.retryButton.addTarget(
            self,
            action: #selector(retry),
            for: .touchUpInside
        )
        self.retryButton.setTitle(
            NSLocalizedString("Retry", bundle: .primeSdk, comment: ""),
            for: .normal
        )

        self.setupFonts()
    }

    var text: String? {
        get {
            return self.textLabel.text
        }

        set {
            self.textLabel.text = newValue
        }
    }

    @objc
    private func retry() {
        self.retryAction?()
    }

    func align() {
        guard let superview = self.superview else {
            return
        }

        //TODO: need to discus value -80
        self.centerXAnchor.constraint(
            equalTo: superview.centerXAnchor,
            constant: 0
        ).isActive = true
        self.centerYAnchor.constraint(
            equalTo: superview.centerYAnchor,
            constant: 0
        ).isActive = true

        NSLayoutConstraint.activate(
            [
                self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: 0),
                self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: 0)
            ]
        )
    }

    private func setupFonts() {
        self.textLabel.font = UIFont.font(of: 15, weight: .medium)
        self.retryButton.titleLabel?.font = UIFont.font(of: 15, weight: .regular)
    }
}
