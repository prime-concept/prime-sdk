import UIKit

class DetailHorizontalCardView: UIView, ProgrammaticallyDesignable {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: 0x808080)
        label.numberOfLines = 3
        return label
    }()

    private lazy var shadowBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    init() {
        super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
        self.setupFonts()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(model: ListItemViewModel) {
        self.titleLabel.text = model.title
        self.subtitleLabel.text = model.subtitle
    }

    func clear() {
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
    }

    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
    }

    func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
        }

        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.bottom.trailing.leading.equalToSuperview().inset(10)
        }
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 16, weight: .bold)
        self.subtitleLabel.font = UIFont.font(of: 12, weight: .regular)
    }
}
