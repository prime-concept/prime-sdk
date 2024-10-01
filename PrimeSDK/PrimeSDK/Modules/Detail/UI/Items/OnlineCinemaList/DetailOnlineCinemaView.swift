import Nuke
import UIKit

extension DetailOnlineCinemaView {
    struct Appearance {
        let stackViewHeight: CGFloat = 70
        let iconHeight: CGFloat = 24
        let iconStackViewSpacing: CGFloat = 5
        let sideOffset: CGFloat = 15
        let iconCornerRadius: CGFloat = 7
    }
}

final class DetailOnlineCinemaView: UIView {
    let appearance: Appearance

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = self.appearance.iconCornerRadius
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.8
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()

    lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: self.appearance.sideOffset,
            bottom: 0,
            right: self.appearance.sideOffset
        )
        scrollView.setContentOffset(CGPoint(x: -self.appearance.sideOffset, y: 0), animated: false)

        return scrollView
    }()

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = backgroundColor ?? .white
            titleLabel.textColor = color.isLight() ? .black : .white
            stackView.views.forEach { $0.backgroundColor = backgroundColor }
        }
    }

    lazy var stackView: ContainerStackView = {
        var stackView = ContainerStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()

    private var viewModel: DetailOnlineCinemaViewModel

    var onLinkTap: ((TypeGroupedPricesViewModel, String) -> Void)?

    init(viewModel: DetailOnlineCinemaViewModel, appearance: Appearance = Appearance()) {
        self.viewModel = viewModel
        self.appearance = appearance
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()
        self.update(with: viewModel)
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with viewModel: DetailOnlineCinemaViewModel) {
        self.viewModel = viewModel

        self.titleLabel.text = viewModel.title
        if let url = URL(string: viewModel.imagePath) {
            Nuke.loadImage(with: url, into: self.iconImageView)
        }

        self.stackView.resetViews()
        for groupedPrices in viewModel.typeGroupedPricesList {
            let view = DetailOnlineGroupedPricesView(viewModel: groupedPrices, tapLink: viewModel.link)
            view.backgroundColor = self.backgroundColor
            view.onLinkTap = { [weak self] in
                self?.onLinkTap?(groupedPrices, viewModel.link)
            }
            self.stackView.addView(view: view)
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: appearance.stackViewHeight + appearance.iconHeight + appearance.iconStackViewSpacing
        )
    }

    private func addSubviews() {
        [
            self.iconImageView,
            self.titleLabel,
            self.scrollView
        ].forEach {
            self.addSubview($0)
        }

        self.scrollView.addSubview(self.stackView)
    }

    private func makeConstraints() {
        self.iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(self.appearance.iconHeight)
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.sideOffset)
            make.trailing.equalTo(self.titleLabel.snp.leading).offset(-5)
            make.bottom.equalTo(self.scrollView.snp.top).offset(-5)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.sideOffset)
            make.centerY.equalTo(self.iconImageView.snp.centerY)
        }

        self.scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.stackView.snp.height)
        }

        self.stackView.snp.makeConstraints { make in
            make.height.equalTo(70)
            make.edges.equalToSuperview()
        }
    }
}
