import UIKit

class ChangeCityTableHeaderView: UITableViewHeaderFooterView, NibLoadable, ViewReusable {
    @IBOutlet private weak var headerTextLabel: UILabel!

    private var themeProvider: ThemeProvider?

    var headerText: String? {
        didSet {
            self.headerTextLabel.text = self.headerText
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.themeProvider = ThemeProvider(themeUpdatable: self)
        self.headerTextLabel.font = UIFont.font(of: 14, weight: .bold)
    }

    func setup(with text: String?) {
        self.headerText = text
    }
}

extension ChangeCityTableHeaderView: ThemeUpdatable {
    func update(with theme: Theme) {
        self.headerTextLabel.textColor = theme.palette.accent
    }
}
