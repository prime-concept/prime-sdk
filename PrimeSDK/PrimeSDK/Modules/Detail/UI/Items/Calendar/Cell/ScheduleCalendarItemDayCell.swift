import UIKit

final class ScheduleCalendarItemDayCell: TileCollectionViewCell<
    TicketsBookerCalendarItemView, KinohodTicketsBookerCalendarViewModel.DayItem
>, ViewReusable {
//    lazy var dayItemView: DetailCalendarDayItemView = .fromNib()

    override var topAnchorConstant: CGFloat { return 0 }
    override var bottomAnchorConstant: CGFloat { return -6 }
    override var leadingAnchorConstant: CGFloat { return 0 }
    override var trailingAnchorConstant: CGFloat { return 0 }

    override init(frame: CGRect) {
        super.init(frame: frame)

        tileView.cornerRadius = 8
        tileView.selectedShadowColor = UIColor.black.withAlphaComponent(0.15)
        tileView.shadowRadius = 4
        tileView.shadowOffset = CGSize(width: 0, height: 2)
        tileView.cellBackgroundColor = .white
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(with viewModel: KinohodTicketsBookerCalendarViewModel.DayItem) {
        tileView.topText = viewModel.dayOfWeek
        tileView.mainText = viewModel.dayNumber
        tileView.bottomText = viewModel.month

        tileView.state = viewModel.hasData ? .withEvents : .withoutEvents
    }
}
