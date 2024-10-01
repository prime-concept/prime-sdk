import Foundation

import UIKit

protocol HomeColoredContainerViewProtocol: AnyObject {
    func update(viewModel: HomeColoredContainerViewModel)
}

class HomeColoredContainerViewController: UIViewController, HomeColoredContainerViewProtocol {
    private lazy var noInternetView: NoInternetView = .fromNib()

    var presenter: HomeColoredContainerPresenterProtocol?
    var viewModel: HomeColoredContainerViewModel?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 25, weight: .bold)
        label.textColor = .black
        return label
    }()

    lazy var containerView: GradientContainerView = {
        let view = GradientContainerView()
        return view
    }()

    lazy var stackView: ContainerStackView = {
        let view = ContainerStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        [
            containerView
        ].forEach(view.addSubview)
        [
            self.titleLabel,
            self.stackView
        ].forEach(containerView.addSubview)

        self.containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(5)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(25)
            make.height.equalTo(31)
        }

        self.stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-25)
        }

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.refresh()
    }

    func reload(blocks: [HomeBlockModule]) {
        let views: [UIView] = blocks.map { block in
            switch block {
            case .view(let view):
                return view
            case .viewController(let viewController):
                addChild(viewController)
                return viewController.view
            }
        }

        stackView.resetViews()

        for view in views {
            stackView.addView(view: view)
        }
        self.view.layoutIfNeeded()
    }

    func update(viewModel: HomeColoredContainerViewModel) {
        self.viewModel = viewModel
        self.containerView.layer.cornerRadius = CGFloat(viewModel.radius)
        self.titleLabel.text = viewModel.title
        self.titleLabel.textColor = viewModel.titleColor
        self.containerView.colors = [
            viewModel.backgroundColorTop.cgColor,
            viewModel.backgroundColorBottom.cgColor
        ]

        reload(
            blocks: viewModel.subviews.compactMap {
                $0.makeModule()
            }
        )
    }
}
