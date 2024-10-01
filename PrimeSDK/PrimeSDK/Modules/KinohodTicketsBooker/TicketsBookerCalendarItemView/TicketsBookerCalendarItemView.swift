import Foundation

final class TicketsBookerCalendarItemView: BaseTileView {
    enum State {
        case selected, withEvents, withoutEvents
    }

    private static let selectedColor: UIColor = .black
    private static let topLabelWithEventsColor = UIColor(
        red: 0.5,
        green: 0.5,
        blue: 0.5,
        alpha: 0.75
    )
    private static let topLabelWithoutEventsColor = UIColor(
        red: 0.75,
        green: 0.75,
        blue: 0.75,
        alpha: 1
    )
    private static let mainLabelWithoutEventsColor = UIColor(
        red: 0.5,
        green: 0.5,
        blue: 0.5,
        alpha: 0.75
    )
    var cellBackgroundColor = UIColor(
        red: 0.95,
        green: 0.95,
        blue: 0.95,
        alpha: 1
    )
    var selectedShadowColor = UIColor.clear

    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var mainLabel: UILabel!

    var onClick: (() -> Void)?
    var topText: String? {
        didSet {
            topLabel.text = topText
        }
    }

    var mainText: String? {
        didSet {
            mainLabel.text = mainText
        }
    }

    var bottomText: String? {
        didSet {
            bottomLabel.text = bottomText
        }
    }

    var state: State = .withEvents {
        didSet {
            switch state {
            case .selected:
                setSelectedState()
            case .withEvents:
                setWithEventsState()
            case .withoutEvents:
                setWithoutEventsState()
            }
        }
    }

    private var skeletonView: TicketsBookerCalendarItemSkeletonView = .fromNib()

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

    private func setupFonts() {
        self.topLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.mainLabel.font = UIFont.font(of: 16, weight: .semibold)
        self.bottomLabel.font = UIFont.font(of: 12, weight: .semibold)
    }

    private func setElements(hidden: Bool) {
        bottomLabel.isHidden = hidden
        topLabel.isHidden = hidden
        mainLabel.isHidden = hidden
    }

    @IBAction func onItemClick(_ sender: Any) {
        onClick?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addSubview(self.skeletonView)
        self.skeletonView.layer.cornerRadius = 10
        self.skeletonView.alignToSuperview()
        self.isSkeletonShown = false

        self.clipsToBounds = true
        self.layer.cornerRadius = 10

        self.state = .withEvents
        self.setupFonts()
    }

    private func setSelectedState() {
        color = selectedShadowColor
        layer.backgroundColor = cellBackgroundColor.cgColor
        topLabel.textColor = TicketsBookerCalendarItemView.selectedColor
        mainLabel.textColor = TicketsBookerCalendarItemView.selectedColor
        bottomLabel.textColor = TicketsBookerCalendarItemView.selectedColor
        skeletonView.isBottomLabelHidden = false
    }

    private func setWithEventsState() {
        color = .clear
        layer.backgroundColor = UIColor.clear.cgColor
        topLabel.textColor = TicketsBookerCalendarItemView.topLabelWithEventsColor
        mainLabel.textColor = .black
        bottomLabel.textColor = .clear
        skeletonView.isBottomLabelHidden = true
    }

    private func setWithoutEventsState() {
        color = .clear
        layer.backgroundColor = UIColor.clear.cgColor
        topLabel.textColor = TicketsBookerCalendarItemView.topLabelWithoutEventsColor
        mainLabel.textColor = TicketsBookerCalendarItemView.mainLabelWithoutEventsColor
        bottomLabel.textColor = .clear
        skeletonView.isBottomLabelHidden = true
    }
}

