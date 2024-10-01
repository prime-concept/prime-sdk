import UIKit

final class CalendarDayFakeButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            } else {
                self.backgroundColor = .clear
            }
        }
    }
}

final class DetailCalendarDayItemView: BaseTileView {
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

    @IBAction func onItemClick(_ sender: Any) {
        onClick?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.clipsToBounds = true
        self.layer.cornerRadius = 10

        self.state = .withEvents

        self.setupFonts()
    }

    private func setupFonts() {
        self.topLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.mainLabel.font = UIFont.font(of: 16, weight: .semibold)
        self.bottomLabel.font = UIFont.font(of: 12, weight: .semibold)
    }

    private func setSelectedState() {
        color = selectedShadowColor
        layer.backgroundColor = cellBackgroundColor.cgColor
        topLabel.textColor = DetailCalendarDayItemView.selectedColor
        mainLabel.textColor = DetailCalendarDayItemView.selectedColor
        bottomLabel.textColor = DetailCalendarDayItemView.selectedColor
    }

    private func setWithEventsState() {
        color = .clear
        layer.backgroundColor = UIColor.clear.cgColor
        topLabel.textColor = DetailCalendarDayItemView.topLabelWithEventsColor
        mainLabel.textColor = .black
        bottomLabel.textColor = .clear
    }

    private func setWithoutEventsState() {
        color = .clear
        layer.backgroundColor = UIColor.clear.cgColor
        topLabel.textColor = DetailCalendarDayItemView.topLabelWithoutEventsColor
        mainLabel.textColor = DetailCalendarDayItemView.mainLabelWithoutEventsColor
        bottomLabel.textColor = .clear
    }
}
