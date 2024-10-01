import Foundation

final class InAppShowMapFakeButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            } else {
                self.backgroundColor = .clear
            }
        }
    }
}

final class CinemaShowMapView: UIView, NibLoadable {
    @IBOutlet private weak var titleLabel: UILabel!
    private var themeProvider: ThemeProvider?

    var onTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.themeProvider = ThemeProvider(themeUpdatable: self)
        self.titleLabel.font = UIFont.font(of: 20, weight: .bold)
    }

    @IBAction private func onOpenInAppButtonTap() {
        self.onTap?()
    }
}

extension CinemaShowMapView: ThemeUpdatable {
    func update(with theme: Theme) {
        self.titleLabel.textColor = theme.palette.accent
    }
}
