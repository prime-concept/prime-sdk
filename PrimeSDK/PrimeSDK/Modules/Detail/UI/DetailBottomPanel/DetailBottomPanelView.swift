import UIKit

final class DetailBottomPanelView: UIView {
    var height: CGFloat {
        return 56
            + eventLabel.frame.height
            + dayLabel.frame.height
            + stackView.frame.height
    }

    @IBOutlet private weak var notificationElement: UIView!

    @IBOutlet private weak var eventLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var notificationLabel: UILabel!
    @IBOutlet private weak var addToCalendarLabel: UILabel!

    var onAddToCalendarAction: (() -> Void)?
    var onAddNotificationAction: (() -> Void)?

    @IBAction func onNotificationButtonClick(_ sender: Any) {
        onAddNotificationAction?()
    }

    @IBAction func onCalendarButtonTap(_ sender: Any) {
        onAddToCalendarAction?()
    }

    override func awakeFromNib() {
        self.notificationLabel.text = ""
        self.addToCalendarLabel.text = ""
        self.setupFonts()
    }

    func update(date: String, event: String, canAddNotification: Bool) {
        dayLabel.text = date
        eventLabel.text = event

        notificationElement.isHidden = !canAddNotification
    }

    func setup(with notificationText: String, addToCalendarText: String) {
        notificationLabel.text = notificationText
        addToCalendarLabel.text = addToCalendarText
    }

    private func setupFonts() {
        self.eventLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.dayLabel.font = UIFont.font(of: 16, weight: .semibold)
        self.notificationLabel.font = UIFont.font(of: 15, weight: .semibold)
        self.addToCalendarLabel.font = UIFont.font(of: 15, weight: .semibold)
    }
}
