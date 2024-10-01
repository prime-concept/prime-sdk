import Foundation

class FilterItemTileView: BaseTileView, ViewReusable, NibLoadable {
    @IBOutlet private weak var titleLabel: UILabel!

    private var themeProvider: ThemeProvider?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 0.5
        self.layer.borderColor = titleLabel.textColor.cgColor

        self.color = .clear
        self.titleLabel.font = UIFont.font(of: 16, weight: .bold)
        self.themeProvider = ThemeProvider(themeUpdatable: self)
    }

    func setup(viewModel: FilterItemViewModel) {
        self.titleLabel.text = viewModel.title
    }

    func reset() {
        self.titleLabel.text = nil
    }
}

extension FilterItemTileView: ThemeUpdatable {
    func update(with theme: Theme) {
        self.titleLabel.textColor = theme.palette.accent
    }
}
