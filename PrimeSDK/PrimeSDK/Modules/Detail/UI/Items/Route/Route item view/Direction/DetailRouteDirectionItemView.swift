import UIKit

final class DetailRouteDirectionItemView: UIView {
    @IBOutlet private weak var descriptionLabel: UILabel!

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: descriptionLabel.intrinsicContentSize.height
        )
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.descriptionLabel.font = UIFont.font(of: 12, weight: .semibold)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }

    func update(description: String) {
        descriptionLabel.setText(description, lineSpacing: 3.0, alignment: .center)
    }
}
