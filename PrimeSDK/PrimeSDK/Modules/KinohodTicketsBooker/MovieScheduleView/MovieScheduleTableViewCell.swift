import UIKit

class MovieScheduleTableViewCell: UITableViewCell, ViewReusable {
    lazy var scheduleView: MovieScheduleView = {
        let view: MovieScheduleView = .fromNib()
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: 0
        ).isActive = true
        view.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: 0
        ).isActive = true
        view.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 0
        ).isActive = true
        view.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: 0
        ).isActive = true

        return view
    }()

    func update(
        with viewModel: KinohodTicketsBookerScheduleViewModel.ScheduleRow,
        isSkeletonShown: Bool,
        onSelect: ((KinohodTicketsBookerScheduleViewModel.Schedule) -> Void)?
    ) {
        scheduleView.update(
            viewModel: viewModel,
            isSkeletonShown: isSkeletonShown,
            onSelect: onSelect
        )
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
