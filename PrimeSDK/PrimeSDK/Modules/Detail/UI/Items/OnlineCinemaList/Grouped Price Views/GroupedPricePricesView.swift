import UIKit

extension GroupedPricePricesView {
    struct Appearance {
        let cornerRadius: CGFloat = 8
        let darkBackgroundContainerColor = UIColor.white.withAlphaComponent(0.1)
        let lightBackgroundContainerColor = UIColor.black.withAlphaComponent(0.05)
    }
}

final class GroupedPricePricesView: UIView {
    private let appearance: Appearance

    private lazy var containerView: ContainerStackView = {
        let view = ContainerStackView()
        view.spacing = 0
        view.axis = .horizontal
        return view
    }()

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = backgroundColor ?? .white

            self.containerView.backgroundColor = color.isLight() ?
                appearance.lightBackgroundContainerColor : appearance.darkBackgroundContainerColor

            self.separatorViews.forEach { $0.backgroundColor = backgroundColor }
            self.priceViews.forEach { $0.backgroundColor = backgroundColor }
        }
    }

    private var separatorViews: [UIView] = []
    private var priceViews: [UIView] = []

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

    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.bottomLeft, .bottomRight], radius: self.appearance.cornerRadius)
    }

    func setup(prices: [SinglePriceViewModel], type: String) {
        self.containerView.resetViews()
        self.separatorViews = []
        self.priceViews = []

        switch type {
        case "SVOD":
            if let subscriptionPrice = prices.first {
                let subscriptionView = GroupedPriceSubscriptionPriceView()
                subscriptionView.backgroundColor = self.backgroundColor
                subscriptionView.setup(price: subscriptionPrice)
                self.priceViews += [subscriptionView]
                self.containerView.addView(view: subscriptionView)
            }
        default:
            for price in prices {
                let priceView = GroupedPriceQualityPriceView()
                priceView.backgroundColor = self.backgroundColor
                priceView.setup(price: price)
                if !self.priceViews.isEmpty {
                    let separatorView = self.makeSeparatorView()
                    self.separatorViews += [separatorView.separator]
                    self.containerView.addView(view: separatorView.container)
                }
                self.priceViews += [priceView]
                self.containerView.addView(view: priceView)
            }
        }


        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func makeSeparatorView() -> (separator: UIView, container: UIView) {
        let separatorContainerView = UIView()
        separatorContainerView.backgroundColor = .clear
        let separatorView = UIView()
        separatorView.backgroundColor = self.backgroundColor
        separatorContainerView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalTo(44)
            make.top.bottom.equalToSuperview().inset(5)
        }
        return (separator: separatorView, container: separatorContainerView)
    }

    private func addSubviews() {
        self.addSubview(self.containerView)
    }

    private func makeConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


