import SnapKit

class CancelBookingActionView: UIView {
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(hex: 0xC9826D), for: .normal)
        button.setTitle("Cancel Booking", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        return button
    }()

    private lazy var horizontalSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xEAEAEA)
        return view
    }()

    var onCancel: (() -> Void)?

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
            self.cancelButton,
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

        self.cancelButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.horizontalSeparatorView.snp.bottom)
            make.height.equalTo(50)
        }
    }

    @objc
    func cancelPressed() {
        self.onCancel?()
    }
}
