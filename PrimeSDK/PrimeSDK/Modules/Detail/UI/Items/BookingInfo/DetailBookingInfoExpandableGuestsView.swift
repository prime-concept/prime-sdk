import SnapKit
import UIKit

class DetailBookingInfoExpandableGuestsView: UIView {
    private var isExpanded: Bool
    private var shouldShrink = false

    var onLayoutUpdate: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return label
    }()

    private lazy var guestsContainerView: ContainerStackView = {
        let view = ContainerStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    private let arrowDownImage = UIImage(named: "arrow-down", in: .primeSdk, compatibleWith: nil)
    private let arrowUpImage = UIImage(named: "arrow-up", in: .primeSdk, compatibleWith: nil)

    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: arrowDownImage)
        return imageView
    }()

    private lazy var expandButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(expandChanged), for: .touchUpInside)
        return button
    }()

    init(guests: [DetailBookingGuest]) {
        self.isExpanded = !self.shouldShrink

        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()

        switch guests.count % 10 {
        case 0, 5, 6, 7, 8, 9:
            self.titleLabel.text = "\(guests.count) \(NSLocalizedString("Guests056789", bundle: .primeSdk, comment: ""))"
        case 1:
            self.titleLabel.text = "\(guests.count) \(NSLocalizedString("Guests1", bundle: .primeSdk, comment: ""))"
        case 2, 3, 4:
            self.titleLabel.text = "\(guests.count) \(NSLocalizedString("Guests234", bundle: .primeSdk, comment: ""))"
        default:
            break
        }

        self.addGuests(guests: guests)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func expandChanged() {
        guard self.shouldShrink else {
            return
        }
        self.isExpanded.toggle()
        if self.isExpanded {
            self.arrowImageView.image = self.arrowUpImage
            self.setExpandedConstraints()
        } else {
            self.arrowImageView.image = self.arrowDownImage
            self.setCompactConstraints()
        }
        self.onLayoutUpdate?()
        self.guestsContainerView.isHidden = !self.isExpanded
    }

    private func addSubviews() {
        [
            self.titleLabel,
            self.guestsContainerView,
            self.arrowImageView,
            self.expandButton
        ].forEach {
            self.addSubview($0)
        }
    }

    private func setExpandedConstraints() {
        self.titleLabel.snp.removeConstraints()
        self.titleLabel.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview()
        }

        self.guestsContainerView.snp.removeConstraints()
        self.guestsContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
        }
    }

    private func setCompactConstraints() {
        self.titleLabel.snp.removeConstraints()
        self.titleLabel.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        self.guestsContainerView.snp.removeConstraints()
        self.guestsContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
    }

    private func makeConstraints() {
        self.expandButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.arrowImageView.snp.makeConstraints { make in
            make.height.width.equalTo(15)
            make.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(3)
        }

        self.arrowImageView.isHidden = !self.shouldShrink
        self.isExpanded ? self.setExpandedConstraints() : self.setCompactConstraints()
    }

    private func addGuests(guests: [DetailBookingGuest]) {
        self.guestsContainerView.resetViews()
        for guest in guests {
            let guestView = DetailBookingInfoGuestRowView(guest: guest)
            self.guestsContainerView.addView(view: guestView)
        }
    }
}
