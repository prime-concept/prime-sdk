import SwiftMessages
import UIKit

class TextNotificationView: BaseView {
    private var textLabel: UILabel?

    var text: String? {
        didSet {
            textLabel?.text = text
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if textLabel == nil {
            initView()
        }
    }

    private func initView() {
        translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentView)
        NSLayoutConstraint.activate(
            [
                contentView.topAnchor.constraint(
                    equalTo: layoutMarginsGuide.topAnchor,
                    constant: 0
                ),
                contentView.bottomAnchor.constraint(
                    equalTo: layoutMarginsGuide.bottomAnchor,
                    constant: 0
                ),
                contentView.leftAnchor.constraint(
                    equalTo: layoutMarginsGuide.leftAnchor,
                    constant: 0
                ),
                contentView.rightAnchor.constraint(
                    equalTo: layoutMarginsGuide.rightAnchor,
                    constant: 0
                ),
                contentView.heightAnchor.constraint(
                    equalToConstant: 46
                )
            ]
        )

        backgroundColor = UIColor(
            red: 0.25,
            green: 0.25,
            blue: 0.25,
            alpha: 0.75
        )

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.font(of: 12)

        contentView.addSubview(label)
        label.centerYAnchor.constraint(
            equalTo: contentView.centerYAnchor
        ).isActive = true
        label.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 0
        ).isActive = true
        label.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: 0
        ).isActive = true

        self.textLabel = label
    }
}
