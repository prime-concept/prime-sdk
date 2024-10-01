import UIKit

final class DetailShortInfoView: UIView {
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet weak var ageLabel: PaddingLabel!
    @IBOutlet var subtitleConstraintToSafeArea: NSLayoutConstraint!
    @IBOutlet var subtitleConstraintToSmallLabel: NSLayoutConstraint!
    @IBOutlet var bottomSubtitleConstraint: NSLayoutConstraint!

    private static let ageLabelBackgroundColor = UIColor(
        red: 0.95,
        green: 0.95,
        blue: 0.95,
        alpha: 1
    )

    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
            bottomSubtitleConstraint.constant = (subtitle ?? "").isEmpty ? 0 : 15
        }
    }

    var smallText: String? {
        didSet {
            ageLabel.isHidden = (smallText ?? "").isEmpty
            ageLabel.text = smallText
            subtitleConstraintToSafeArea.priority = ageLabel.isHidden
                                                 ? .defaultHigh
                                                 : .defaultLow
            subtitleConstraintToSmallLabel.priority = ageLabel.isHidden
                                                    ? .defaultLow
                                                    : .defaultHigh
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.ageLabel.layer.cornerRadius = 3
        self.ageLabel.layer.backgroundColor = DetailShortInfoView.ageLabelBackgroundColor.cgColor

        self.subtitle = nil
        self.smallText = nil

        self.setupFonts()
    }

    private func setupFonts() {
        self.subtitleLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.ageLabel.font = UIFont.font(of: 10, weight: .bold)
    }
}
