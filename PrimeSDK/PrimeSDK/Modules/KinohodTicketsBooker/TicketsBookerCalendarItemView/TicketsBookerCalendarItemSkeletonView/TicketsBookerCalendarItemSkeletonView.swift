import Foundation

final class TicketsBookerCalendarItemSkeletonView: UIView, NibLoadable {
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var mainLabel: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!

    var isBottomLabelHidden: Bool = false {
        didSet {
            bottomLabel.isHidden = isBottomLabelHidden
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupFonts()
    }

    private func setupFonts() {
        self.topLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.mainLabel.font = UIFont.font(of: 16, weight: .semibold)
        self.bottomLabel.font = UIFont.font(of: 12, weight: .semibold)
    }
}
