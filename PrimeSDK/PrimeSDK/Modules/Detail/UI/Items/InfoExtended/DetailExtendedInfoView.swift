import UIKit

final class DetailExtendedInfoView: UIView, ProgrammaticallyDesignable {
    private enum Appearance {
        static let lightTitleColor = UIColor.white
        static let darkTitleColor = UIColor.black
        static let titleFont = UIFont.font(of: 14, weight: .bold)

        static let subtitleColor = UIColor.white.withAlphaComponent(0.5)
        static let subtitleFont = UIFont.font(of: 14, weight: .medium)
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    private var textColor: UIColor = .black

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = backgroundColor ?? .white
            textColor = color.isLight() ? Appearance.darkTitleColor : Appearance.lightTitleColor
        }
    }

    init() {
        super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Setup view parameters (e.g. set colors, fonts, etc)
    func setupView() {
    }

    /// Set up subviews hierarchy
    func addSubviews() {
        self.addSubview(self.stackView)
    }

    /// Add constraints
    func makeConstraints() {
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }

    func setup(with viewModel: DetailExtendedInfoViewModel) {
        self.backgroundColor = viewModel.backgroundColor
        self.makeRows(from: viewModel.rows)
    }

    // MARK: - Private

    private func makeRows(from rows: [DetailExtendedInfoViewModel.BlockInfo]) {
        for row in rows {
            let view = self.makeContainer(title: row.title, subtitle: row.subtitle)
            self.stackView.addArrangedSubview(view)
        }
    }

    private func makeContainer(title: String, subtitle: String) -> UIView {
        let view = UIView()

        let titleLabel = UILabel()
        titleLabel.font = Appearance.titleFont
        titleLabel.textColor = textColor
        titleLabel.numberOfLines = 0
        titleLabel.text = title
        view.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.font = Appearance.subtitleFont
        subtitleLabel.textColor = textColor.withAlphaComponent(0.5)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = subtitle
        view.addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.leading.trailing.equalToSuperview()
        }

        return view
    }
}
