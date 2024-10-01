import UIKit

final class DetailShareView: UIView {
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!

    var onShare: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.shareButton.layer.cornerRadius = 16.0

        self.setupFonts()
    }

    func setup(viewModel: DetailShareViewModel) {
        self.shareButton.setTitle(viewModel.buttonTitle, for: .normal)
        self.titleLabel.text = viewModel.title
    }

    @IBAction func onShareButtonTouch(_ button: UIButton) {
        self.onShare?()
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 16, weight: .semibold)
        self.shareButton.titleLabel?.font = UIFont.font(of: 15, weight: .semibold)
    }
}
