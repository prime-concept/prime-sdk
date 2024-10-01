import SnapKit
import UIKit

class DetailBookingInfoGuestRowView: UIView {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        return label
    }()

    init(guest: DetailBookingGuest) {
        super.init(frame: .zero)

        self.nameLabel.text = guest.name
        self.emailLabel.text = guest.email

        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        [
            self.nameLabel,
            self.emailLabel
        ].forEach(self.addSubview)
    }

    private func makeConstraints() {
        self.nameLabel.snp.makeConstraints { make in
            make.height.equalTo(17)
            make.leading.trailing.top.equalToSuperview()
        }

        self.emailLabel.snp.makeConstraints { make in
            make.height.equalTo(12)
            make.top.equalTo(self.nameLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

