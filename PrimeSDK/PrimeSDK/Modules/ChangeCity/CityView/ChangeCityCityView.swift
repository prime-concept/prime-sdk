import UIKit

class ChangeCityCityView: UIView, NibLoadable {
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var tickImageView: UIImageView!

    private var themeProvider: ThemeProvider?

    var cityName: String? {
        didSet {
            self.textLabel.text = self.cityName
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.tickImageView.image = UIImage(
            named: "change-city-tick",
            in: .primeSdk,
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)
        self.textLabel.font = UIFont.font(of: 16)

        self.themeProvider = ThemeProvider(themeUpdatable: self)
    }

    var isSelected: Bool = false {
        didSet {
            self.tickImageView.isHidden = !self.isSelected
        }
    }

    func setup(cityName: String, isSelected: Bool) {
        self.cityName = cityName
        self.isSelected = isSelected
    }
}

extension ChangeCityCityView: ThemeUpdatable {
    func update(with theme: Theme) {
        self.tickImageView.tintColor = theme.palette.accent
    }
}
