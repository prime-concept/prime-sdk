import UIKit

extension GroupedPriceQualityPriceView {
    struct Appearance {
        let darkBackgroundContainerColor = UIColor.white.withAlphaComponent(0.1)
        let lightBackgroundContainerColor = UIColor.black.withAlphaComponent(0.05)

        let darkBackgroundQualityColor = UIColor.white.withAlphaComponent(0.5)
        let lightBackgroundQualityColor = UIColor.black.withAlphaComponent(0.5)

        let darkBackgroundPriceColor = UIColor.white
        let lightBackgroundPriceColor = UIColor.black
    }
}

final class GroupedPriceQualityPriceView: UIView {
    private let appearance: Appearance

    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var qualityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = backgroundColor ?? .white

            qualityLabel.textColor = color.isLight() ?
                appearance.lightBackgroundQualityColor : appearance.darkBackgroundQualityColor
            priceLabel.textColor = color.isLight() ?
                appearance.lightBackgroundPriceColor : appearance.darkBackgroundPriceColor
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
        self.priceLabel.isHidden = true
        if let amount = price.price, let currency = price.displayCurrency {
            self.priceLabel.text = "\(amount)\(currency)"
            self.priceLabel.isHidden = false
        }
        self.qualityLabel.text = price.quality.uppercased()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func addSubviews() {
        self.addSubview(self.containerView)

        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.spacing = 2

        self.containerView.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges
                .equalToSuperview()
                .inset(UIEdgeInsets(top: 12, left: 15, bottom: 10, right: 15))
        }

        mainStack.addArrangedSubview(self.qualityLabel)
        mainStack.addArrangedSubview(self.priceLabel)
    }

    private func makeConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(66)
        }

        self.qualityLabel.snp.makeConstraints { make in
            make.height.equalTo(17)
        }

        self.priceLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
        }
    }
}
