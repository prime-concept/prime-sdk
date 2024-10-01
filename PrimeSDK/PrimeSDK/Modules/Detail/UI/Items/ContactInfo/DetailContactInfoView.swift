import UIKit

final class DetailContactInfoView: UIView, ProgrammaticallyDesignable {
    private enum Appearance {
        static let phoneButtonCornerRadius = CGFloat(8)
        static let shadowColor = UIColor.black
        static let shadowRadius = CGFloat(7)
        static let shadowOpacity = Float(0.1)
        static let shadowOffset = CGSize(width: 0, height: 2)
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.axis = .horizontal
        stackView.spacing = 19
        return stackView
    }()

    private lazy var linksStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()

    private lazy var phoneBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var phoneButton: UIButton = {
        let button = UIButton()

        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)

        button.layer.cornerRadius = Appearance.phoneButtonCornerRadius
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)

        button.addTarget(self, action: #selector(onPhoneButtonTap), for: .touchUpInside)

        return button
    }()

    private var phone: String? {
        didSet {
            self.phoneBackgroundView.isHidden = (self.phone ?? "").isEmpty
            self.phoneButton.setTitle(self.phone, for: .normal)
            self.dropShadow()
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

    private func dropShadow() {
        self.phoneButton.layer.shadowColor = Appearance.shadowColor.cgColor
        self.phoneButton.layer.shadowOpacity = Appearance.shadowOpacity
        self.phoneButton.layer.shadowOffset = Appearance.shadowOffset
        self.phoneButton.layer.shadowRadius = Appearance.shadowRadius
        self.phoneButton.layer.shouldRasterize = true
        self.phoneButton.layer.rasterizationScale = UIScreen.main.scale
        self.phoneButton.layer.masksToBounds = false
    }

    @objc
    private func onPhoneButtonTap() {
        guard let phone = self.phone?.replacingOccurrences(of: " ", with: "") else {
            return
        }
        guard let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    /// Setup view parameters (e.g. set colors, fonts, etc)
    func setupView() {
    }

    /// Set up subviews hierarchy
    func addSubviews() {
        self.addSubview(self.stackView)

        [self.linksStackView, self.phoneBackgroundView].forEach(self.stackView.addArrangedSubview)

        self.phoneBackgroundView.addSubview(phoneButton)
    }

    /// Add constraints
    func makeConstraints() {
        self.stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.lessThanOrEqualToSuperview().offset(-15)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-5)
        }

        self.phoneButton.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
            make.height.equalTo(44)
        }
    }

    func setup(with viewModel: DetailContactInfoViewModel) {
        self.phone = viewModel.phone

        if !viewModel.isLinksAvailable {
            self.linksStackView.isHidden = true
            return
        }

        if let website = viewModel.site {
            let button = ContactLinkButton(type: .website, url: website)

            linksStackView.addArrangedSubview(button)

            button.snp.makeConstraints { make in
                make.height.width.equalTo(44)
            }
        }
    }
}
