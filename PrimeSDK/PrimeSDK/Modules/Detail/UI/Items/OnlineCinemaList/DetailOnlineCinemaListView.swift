import Foundation
import UIKit

class DetailOnlineCinemaListView: UIView {
    private var viewModel: DetailOnlineCinemaListViewModel?
    private let spacing = 15

    private lazy var verticalContainerView: ContainerStackView = {
        let view = ContainerStackView()
        view.axis = .vertical
        view.spacing = 15
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.text = "Смотреть онлайн"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    var onLinkTap: ((TypeGroupedPricesViewModel, String) -> Void)?

    init() {
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()
    }

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = backgroundColor ?? .white
            titleLabel.textColor = color.isLight() ? .black : .white
            verticalContainerView.views.forEach { $0.backgroundColor = backgroundColor }
        }
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with viewModel: DetailOnlineCinemaListViewModel) {
        self.viewModel = viewModel
        self.backgroundColor = viewModel.backgroundColor

        verticalContainerView.resetViews()
        for onlineCinemaViewModel in viewModel.cinemas {
            let cinemaView = DetailOnlineCinemaView(viewModel: onlineCinemaViewModel)
            cinemaView.backgroundColor = self.backgroundColor
            cinemaView.onLinkTap = { [weak self] model, link in
                self?.onLinkTap?(model, link)
            }
            verticalContainerView.addView(view: cinemaView)
        }
    }

    private func addSubviews() {
        [
            self.titleLabel,
            self.verticalContainerView
        ].forEach {
            self.addSubview($0)
        }
    }

    private func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(10)
        }

        self.verticalContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
