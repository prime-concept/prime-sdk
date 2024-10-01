import UIKit

extension GroupedPriceSubscriptionPriceView {
    struct Appearance {
        let darkBackgroundContainerColor = UIColor.white.withAlphaComponent(0.1)
        let lightBackgroundContainerColor = UIColor.black.withAlphaComponent(0.05)
    }
}

final class GroupedPriceSubscriptionPriceView: UIView {
    private let appearance: Appearance

    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private lazy var periodLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.text = "в мес."
        label.textAlignment = .center
        return label
    }()

    private lazy var subscriptionLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var logoContainerView: UIView = {
        let view = UIView()
        view.addSubview(subscriptionLogoImageView)
        subscriptionLogoImageView.snp.makeConstraints { make in
            make.edges
                .equalToSuperview()
                .inset(UIEdgeInsets(top: 16, left: 21, bottom: 18, right: 21))
        }
        return view
    }()

    private lazy var priceContainerView: UIView = {
        let view = UIView()

        view.addSubview(self.priceLabel)
        view.addSubview(self.periodLabel)

        self.priceLabel.snp.makeConstraints { make in
            make.height.equalTo(17)
            make.top.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
        }

        self.periodLabel.snp.makeConstraints { make in
            make.top.equalTo(self.priceLabel.snp.bottom)
            make.height.equalTo(15)
            make.bottom.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
        }

        return view
    }()

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = backgroundColor ?? .white

            priceLabel.textColor = color.isLight() ? .black : .white
            periodLabel.textColor = color.isLight() ? .black : .white
            containerView.backgroundColor = color.isLight() ?
                appearance.lightBackgroundContainerColor : appearance.darkBackgroundContainerColor
        }
    }

    init(appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(price: SinglePriceViewModel) {
        self.logoContainerView.isHidden = true
        self.priceContainerView.isHidden = true

        if let amount = price.price, let currency = price.displayCurrency {
            self.priceLabel.text = "\(amount)\(currency)"
            self.priceContainerView.isHidden = false
        } else if let logo = price.logo {
            self.subscriptionLogoImageView.image = logo
            self.logoContainerView.isHidden = false
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func addSubviews() {
        let mainStack = UIStackView()
        mainStack.axis = .vertical

        self.addSubview(self.containerView)
        self.containerView.addSubview(mainStack)

        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mainStack.addArrangedSubview(priceContainerView)
        mainStack.addArrangedSubview(logoContainerView)
    }

    private func makeConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.greaterThanOrEqualTo(80)
        }
    }
}
