import UIKit

class MovieScheduleTimeCollectionViewCell: UICollectionViewCell, ViewReusable {
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!

    private lazy var skeletonView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 5
        view.isSkeletonable = true
        view.layer.masksToBounds = true
        return view
    }()

    private let unavailableColor = UIColor(
        red: 0.65,
        green: 0.65,
        blue: 0.65,
        alpha: 1
    )

    private var themeProvider: ThemeProvider?

    var time: String? {
        didSet {
            timeLabel.text = time
        }
    }

    var minPrice: Int? {
        didSet {
            var minPriceString: String?
            let availableColor = self.themeProvider?.current.palette.accent ?? .blue
            if let minPrice = minPrice, minPrice != 0 {
                minPriceString = "\(NSLocalizedString("From", bundle: .primeSdk, comment: "")) \(minPrice) ₽"
                priceLabel.text = minPriceString
                priceLabel.isHidden = false
                contentView.layer.borderColor = availableColor.withAlphaComponent(0.3).cgColor
                timeLabel.textColor = availableColor
            } else {
                priceLabel.isHidden = true
                timeLabel.textColor = unavailableColor
                contentView.layer.borderColor = unavailableColor.withAlphaComponent(0.3).cgColor
            }
        }
    }

    var isSkeletonShown: Bool = false {
        didSet {
            skeletonView.translatesAutoresizingMaskIntoConstraints = false
            if isSkeletonShown {
                self.skeletonView.showAnimatedGradientSkeleton()
                setElements(hidden: true)
                self.skeletonView.isHidden = false
            } else {
                self.skeletonView.isHidden = true
                setElements(hidden: false)
                self.skeletonView.hideSkeleton()
            }
        }
    }

    private func setElements(hidden: Bool) {
        timeLabel.isHidden = hidden
        priceLabel.isHidden = hidden

        contentView.layer.borderWidth = hidden ? 0 : 1
    }

    func update(viewModel: KinohodTicketsBookerScheduleViewModel.Schedule) {
        self.time = viewModel.startTimeString
        self.minPrice = viewModel.minPrice
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.addSubview(skeletonView)
        self.skeletonView.alignToSuperview()
        self.isSkeletonShown = false

        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.masksToBounds = true
        self.setupFonts()
    }

    private func setupFonts() {
        self.timeLabel.font = UIFont.font(of: 14, weight: .medium)
        self.priceLabel.font = UIFont.font(of: 10, weight: .semibold)

        self.themeProvider = ThemeProvider(themeUpdatable: self)
    }
}

extension MovieScheduleTimeCollectionViewCell: ThemeUpdatable {
    func update(with theme: Theme) {
    }
}
