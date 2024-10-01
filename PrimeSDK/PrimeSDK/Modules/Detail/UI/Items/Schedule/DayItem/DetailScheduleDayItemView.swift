import UIKit

final class DetailScheduleDayItemView: UIView {
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

    func setup(with item: DetailScheduleViewModel.DaySchedule) {
        self.dayLabel.text = item.title
        self.timeLabel.text = item.timeString

        dayLabel.textColor = item.selected
            ? UIColor.black
            : UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        timeLabel.textColor = item.selected
            ? UIColor.black
            : UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)

        dayLabel.font = item.selected
            ? UIFont.systemFont(ofSize: 16, weight: .bold)
            : UIFont.systemFont(ofSize: 16, weight: .medium)
        timeLabel.font = item.selected
            ? UIFont.systemFont(ofSize: 16, weight: .bold)
            : UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}
