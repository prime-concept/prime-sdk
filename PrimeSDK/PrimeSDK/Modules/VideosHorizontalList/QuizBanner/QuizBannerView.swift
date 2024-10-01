import Foundation
import Nuke

class QuizBannerView: UIView {
    lazy var backgroundGradientContainerView: GradientContainerView = {
        let view = GradientContainerView()
        view.isHorizontal = true
        return view
    }()

    lazy var sloganLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 16, weight: .bold)
        label.textColor = .white
        return label
    }()

    lazy var infoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 10, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 18, weight: .bold)
        label.textColor = .white
        return label
    }()

    lazy var imdbRatingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF5C518)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = false
        return view
    }()

    lazy var imdbRatingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 10, weight: .bold)
        label.textColor = .black
        return label
    }()

    lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        return stackView
    }()

    lazy var prizeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var bannerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle(nil, for: .normal)
        button.setImage(nil, for: .normal)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        return button
    }()

    var didTapBlock: ((String) -> Void)?
    var viewModel: QuizBannerViewModel?
    var themeProvider: ThemeProvider?

    init() {
        super.init(frame: CGRect.zero)

        self.themeProvider = ThemeProvider(themeUpdatable: self)
        self.setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.clipsToBounds = true

        [
            self.backgroundGradientContainerView,
            self.sloganLabel,
            self.avatarImageView,
            self.infoContainerView,
            self.descriptionStackView,
            self.prizeImageView,
            self.bannerButton
        ].forEach(self.addSubview)

        [
            self.subtitleLabel,
            self.titleLabel,
            self.imdbRatingView
        ].forEach(self.infoContainerView.addSubview)

        [
            self.imdbRatingLabel
        ].forEach(self.imdbRatingView.addSubview)

        backgroundGradientContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sloganLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(19)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(sloganLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(60)
            make.width.equalTo(40)
        }

        infoContainerView.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-12)
        }

        descriptionStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(26)
            make.top.equalTo(avatarImageView.snp.bottom).offset(8)
        }

        prizeImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(descriptionStackView.snp.bottom).offset(4)
        }

        bannerButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(12)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(3)
            make.height.equalTo(19)
        }

        imdbRatingView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(9)
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(15)
        }

        imdbRatingLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(3)
            make.trailing.equalToSuperview().offset(-3)
            make.height.equalTo(12)
            make.centerY.equalToSuperview()
        }
    }

    private func updateDescription(descriptions: [String]) {
        descriptionStackView.removeAllArrangedSubviews()

        for description in descriptions {
            let descriptionView = QuizBannerDescriptionItemView(text: description)
            descriptionView.layer.cornerRadius = 13
            descriptionView.layer.masksToBounds = true
            descriptionView.clipsToBounds = true
            descriptionStackView.addArrangedSubview(descriptionView)
        }
        descriptionStackView.layoutIfNeeded()
    }

    func update(viewModel: QuizBannerViewModel) {
        self.viewModel = viewModel
        sloganLabel.text = viewModel.slogan
        subtitleLabel.text = viewModel.subtitle
        titleLabel.text = viewModel.title
        if let rating = viewModel.rating {
            imdbRatingLabel.text = rating
            imdbRatingView.isHidden = false
        } else {
            imdbRatingView.isHidden = true
        }
        updateDescription(descriptions: viewModel.description)
        if let url = URL(string: viewModel.imagePath) {
            Nuke.loadImage(with: url, into: avatarImageView)
        }
        if let url = URL(string: viewModel.prizeImagePath) {
            Nuke.loadImage(with: url, into: prizeImageView)
        }
    }

    @objc
    func didTap() {
        guard let id = viewModel?.id else {
            return
        }
        didTapBlock?(id)
    }
}

extension QuizBannerView: ThemeUpdatable {
    func update(with theme: Theme) {
        self.backgroundGradientContainerView.colors = [
            theme.palette.quizGradientStart.cgColor,
            theme.palette.quizGradientEnd.cgColor
        ]
    }
}
