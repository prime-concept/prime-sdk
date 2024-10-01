import SnapKit

class DetailHeaderStatusView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

    var status: String = "" {
        didSet {
            self.titleLabel.text = status
        }
    }

    init() {
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()

        self.backgroundColor = UIColor(hex: 0x4363B7).withAlphaComponent(0.75)
        self.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        } else {
            // TODO: Do something with this later
        }
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        [
            self.titleLabel
        ].forEach {
            self.addSubview($0)
        }
    }

    private func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(2)
            make.height.equalTo(16)
        }
    }
}
