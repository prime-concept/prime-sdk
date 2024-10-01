import UIKit

final class DetailCalendarDayCollectionViewCell: UICollectionViewCell, ViewReusable {
    lazy var dayItemView: DetailCalendarDayItemView = .fromNib()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(dayItemView)
        dayItemView.translatesAutoresizingMaskIntoConstraints = false
        dayItemView.topAnchor.constraint(
            equalTo: contentView.topAnchor
        ).isActive = true
        dayItemView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor
        ).isActive = true
        dayItemView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor
        ).isActive = true
        dayItemView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor
        ).isActive = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
