import UIKit

class LabeledTileView: ImageTileView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var leftTopLabel: PaddingLabel!
    @IBOutlet private var blurView: UIView!
    private var isInit = false

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var leftTopText: String? {
        didSet {
            blurView.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.text = leftTopText
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupFonts()
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.titleLabel.font = UIFont.font(of: 16, weight: .semibold)
    }
}
