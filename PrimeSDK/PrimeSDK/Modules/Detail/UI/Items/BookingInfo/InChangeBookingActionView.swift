import SnapKit

class InChangeBookingActionView: UIView {
    private lazy var declineButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(hex: 0xC9826D), for: .normal)
        button.setTitle("Decline", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(declinePressed), for: .touchUpInside)
        return button
    }()

    private lazy var acceptButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(hex: 0x4363B7), for: .normal)
        button.setTitle("Accept", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(acceptPressed), for: .touchUpInside)
        return button
    }()

    private lazy var verticalSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xEAEAEA)
        return view
    }()

    private lazy var horizontalSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xEAEAEA)
        return view
    }()

    var onDecline: (() -> Void)?
    var onAccept: (() -> Void)?

    init() {
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        [
            self.declineButton,
            self.acceptButton,
            self.verticalSeparatorView,
            self.horizontalSeparatorView
        ].forEach {
            self.addSubview($0)
        }
    }

    private func makeConstraints() {
        self.horizontalSeparatorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
        }

        self.verticalSeparatorView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        self.declineButton.snp.makeConstraints { make in
            make.trailing.equalTo(verticalSeparatorView.snp.leading)
            make.bottom.leading.equalToSuperview()
            make.top.equalTo(self.horizontalSeparatorView.snp.bottom)
            make.height.equalTo(50)
        }

        self.acceptButton.snp.makeConstraints { make in
            make.leading.equalTo(verticalSeparatorView.snp.trailing)
            make.bottom.trailing.equalToSuperview()
            make.top.equalTo(self.horizontalSeparatorView.snp.bottom)
            make.height.equalTo(50)
        }
    }

    @objc
    func declinePressed() {
        self.onDecline?()
    }

    @objc
    func acceptPressed() {
        self.onAccept?()
    }
}
