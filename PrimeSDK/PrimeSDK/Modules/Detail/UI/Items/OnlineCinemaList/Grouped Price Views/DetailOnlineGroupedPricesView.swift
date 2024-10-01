import UIKit

final class DetailOnlineGroupedPricesView: UIView {
    private lazy var titleView: GroupedPriceTitleView = {
        let view = GroupedPriceTitleView()
        view.backgroundColor = self.backgroundColor
        return view
    }()

    private lazy var pricesView: GroupedPricePricesView = {
        let view = GroupedPricePricesView()
        view.backgroundColor = self.backgroundColor
        return view
    }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.addTarget(
            self,
            action: #selector(onButtonTap),
            for: .touchUpInside
        )
        return button
    }()

    override var backgroundColor: UIColor? {
        didSet {
            self.titleView.backgroundColor = backgroundColor
            self.pricesView.backgroundColor = backgroundColor
        }
    }

    private var tapLink: String

    var onLinkTap: (() -> Void)?

    init(viewModel: TypeGroupedPricesViewModel, tapLink: String) {
        self.tapLink = tapLink
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()
        self.update(with: viewModel)
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with viewModel: TypeGroupedPricesViewModel) {
        titleView.setup(title: viewModel.title)
        pricesView.setup(prices: viewModel.prices, type: viewModel.type)
    }

    private func addSubviews() {
        [
            self.titleView,
            self.pricesView,
            self.button
        ].forEach {
            self.addSubview($0)
        }
    }

    private func makeConstraints() {
        self.titleView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.pricesView.snp.makeConstraints { make in
            make.top.equalTo(self.titleView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(54)
        }

        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc
    private func onButtonTap() {
        self.onLinkTap?()
    }
}
