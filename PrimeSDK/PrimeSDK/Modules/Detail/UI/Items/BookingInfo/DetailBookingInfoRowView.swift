import SnapKit
import UIKit

class DetailBookingInfoRowView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    init(title: String, text: String) {
        super.init(frame: .zero)

        self.titleLabel.text = title
        self.textLabel.text = text

        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        [
            self.titleLabel,
            self.textLabel
        ].forEach(self.addSubview)
    }

    private func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview()
        }

        self.textLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
        }
    }
}
