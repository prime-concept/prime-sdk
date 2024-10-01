import SnapKit

class DetailBookingInfoSuggestionView: UIView {
    private lazy var borderedContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF1D58B).withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: 0xF1D58B).cgColor
        view.clipsToBounds = true
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF1D58B)
        return view
    }()

    private lazy var newConditionsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.black.withAlphaComponent(0.4)
        label.numberOfLines = 1
        label.text = NSLocalizedString("NewConditions", bundle: .primeSdk, comment: "")
        return label
    }()

    private lazy var newConditionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
        return label
    }()

    init(clubName: String, newDate: String, newTime: String) {
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()

        self.titleLabel.text = "\(clubName) \(NSLocalizedString("BookingSuggestionTitle", bundle: .primeSdk, comment: ""))"
        self.newConditionsLabel.text = "\(newDate) \(newTime)"
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        [
            self.borderedContainerView
        ].forEach {
            self.addSubview($0)
        }
        [
            self.titleLabel,
            self.separatorView,
            self.newConditionsTitleLabel,
            self.newConditionsLabel
        ].forEach {
            self.borderedContainerView.addSubview($0)
        }
    }

    private func makeConstraints() {
        self.borderedContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        self.separatorView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }

        self.newConditionsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.separatorView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(21)
        }

        self.newConditionsLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(self.newConditionsTitleLabel.snp.bottom).offset(2)
            make.height.equalTo(21)
            make.bottom.equalToSuperview().inset(15)
        }
    }
}
