import Foundation

final class DetailScheduleView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private weak var shortScheduleView: UIView!
    @IBOutlet private weak var shortScheduleTitleLabel: UILabel!
    @IBOutlet private weak var showFullScheduleButton: UIButton!

    @IBOutlet private weak var fullScheduleView: UIView!
    @IBOutlet private weak var stackView: UIStackView!

    @IBOutlet private weak var shortToSuperviewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var shortToFullBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var fullToSuperviewBottomConstraint: NSLayoutConstraint!

    private var data: [DetailScheduleViewModel.DaySchedule] = []

    private var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var onLayoutUpdate: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func setupFullSchedule() {
        for index in 0..<7 {
            guard let item = self.data[safe: index] else {
                continue
            }

            let view: DetailScheduleDayItemView = .fromNib()
            view.setup(with: item)

            stackView.addArrangedSubview(view)
        }
    }

    private func removeFullSchedule() {
        for view in stackView.subviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func setupButton(with viewModel: DetailScheduleViewModel) {
        self.showFullScheduleButton.setTitle(viewModel.showButtonTitle, for: .normal)
        self.showFullScheduleButton.setTitle(viewModel.hideButtonTitle, for: .selected)

        self.showFullScheduleButton.setTitleColor(
            viewModel.buttonTitleColor,
            for: .normal
        )
        self.showFullScheduleButton.setTitleColor(
            viewModel.buttonTitleColor,
            for: .selected
        )
    }

    func setup(with viewModel: DetailScheduleViewModel) {
        self.data = viewModel.items

        self.shortScheduleTitleLabel.text = viewModel.openStatus
        self.title = viewModel.title

        self.setupButton(with: viewModel)
    }

    @IBAction private func onShowFullScheduleButtonTap(_ button: UIButton) {
        button.isSelected.toggle()

        shortToSuperviewBottomConstraint.priority = button.isSelected ? .defaultLow : .defaultHigh
        shortToFullBottomConstraint.priority = button.isSelected ? .defaultHigh : .defaultLow
        fullToSuperviewBottomConstraint.priority = button.isSelected ? .defaultHigh : .defaultLow

        button.isSelected ? setupFullSchedule() : removeFullSchedule()

        onLayoutUpdate?()
    }
}
