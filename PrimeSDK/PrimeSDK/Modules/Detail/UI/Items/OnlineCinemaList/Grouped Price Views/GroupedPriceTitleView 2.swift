import UIKit

extension GroupedPriceTitleView {
    struct Appearance {
        let cornerRadius: CGFloat = 8
        let darkBackgroundContainerColor = UIColor.white.withAlphaComponent(0.2)
        let lightBackgroundContainerColor = UIColor.black.withAlphaComponent(0.1)
    }
}

final class GroupedPriceTitleView: UIView {
    private let appearance: Appearance

    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 8, weight: .bold)
        return label
    }()

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = backgroundColor ?? .white
            titleLabel.textColor = color.isLight() ? .black : .white
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

    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: self.appearance.cornerRadius)
    }

    func setup(title: String) {
        self.titleLabel.text = title
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func addSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
    }

    private func makeConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(16)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
    }
}
