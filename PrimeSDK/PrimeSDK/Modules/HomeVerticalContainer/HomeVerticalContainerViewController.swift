import UIKit

protocol HomeVerticalContainerViewProtocol: AnyObject {
    func insert(block: HomeContainerBlockViewModelProtocol, atIndex: Int)
    func update(viewModel: HomeVerticalContainerViewModel)
    func updateInternetStatus(isReachable: Bool)
    func setDefaultTopInset(inset: CGFloat)
}

class HomeVerticalContainerViewController: UIViewController, HomeVerticalContainerViewProtocol {
    private lazy var noInternetView: NoInternetView = .fromNib()

    var presenter: HomeVerticalContainerPresenterProtocol?

    var viewModel: HomeVerticalContainerViewModel?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    var homeImageView: HomeImageView?
    var insetView: VerticalInsetView?
    var defaultTopInset: CGFloat = 0

    convenience init() {
        self.init(nibName: "HomeVerticalContainerViewController", bundle: .primeSdk)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
        }
        setupEmptyView()
        presenter?.refresh()
    }

    private func setupEmptyView() {
        view.addSubview(noInternetView)
        noInternetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        noInternetView.isHidden = true
    }

    func insert(block: HomeContainerBlockViewModelProtocol, atIndex pos: Int) {
        guard let module = block.makeModule() else {
            return
        }
        switch module {
        case .view(let view):
            insert(view: view, at: pos)
        case .viewController(let viewController):
            insert(viewController: viewController, at: pos)
        }
    }

    private func insert(view: UIView, at pos: Int) {
        self.stackView.insertArrangedSubview(view, at: pos)
    }

    private func insert(viewController: UIViewController, at pos: Int) {
        addChild(viewController)
        insert(view: viewController.view, at: pos)
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

        stackView.removeAllArrangedSubviews()

        self.insetView = .fromNib()
        if let insetView = insetView {
            if let inset = viewModel?.inset {
                insetView.inset = inset + defaultTopInset

                if let config = self.viewModel?.headerButton?.config,
                    let viewModel = self.viewModel,
                    let header = viewModel.header,
                    let headerButton = viewModel.headerButton,
                    !config.isHidden {
                    self.presenter?.bannerButtonShown(
                        url: headerButton.url,
                        text: headerButton.text,
                        img: header.imagePath ?? "",
                        type: "img"
                    )

                    insetView.config = config
                    insetView.onButtonTap = { [weak self] in
                        self?.handleButtonTap()
                    }
                }
            } else {
                if #available(iOS 11, *) {
                    insetView.inset = CGFloat.leastNonzeroMagnitude + defaultTopInset
                } else {
                    insetView.inset = 1.1 + defaultTopInset
                }
            }
            stackView.addArrangedSubview(insetView)
        }
        for view in views {
            stackView.addArrangedSubview(view)
        }
        self.view.layoutIfNeeded()
    }

    func updateInternetStatus(isReachable: Bool) {
        noInternetView.isHidden = isReachable
    }

    func update(viewModel: HomeVerticalContainerViewModel) {
        self.viewModel = viewModel
        if
            let header = viewModel.header,
            let homeImageViewBlock = header.makeModule()
        {
            switch homeImageViewBlock {
            case .view(let view):
                if let view = view as? HomeImageView {
                    self.homeImageView = view
                    reloadImageViewConstraints(height: header.imageHeight)
                }
            default:
                break
            }
        }
        reload(
            blocks: viewModel.subviews.compactMap {
                $0.makeModule()
            }
        )
    }

    func setDefaultTopInset(inset: CGFloat) {
        defaultTopInset = inset
    }

    private func reloadImageViewConstraints(height: CGFloat) {
        guard let homeImageView = homeImageView else {
            return
        }
        scrollView.insertSubview(homeImageView, belowSubview: stackView)
        homeImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            let statusBarHeight = min(
                UIApplication.shared.statusBarFrame.height,
                UIApplication.shared.statusBarFrame.width
            )
            make.top.equalTo(scrollView.snp.top).offset(-statusBarHeight)
        }
    }

    private func handleButtonTap() {
        guard
            let viewModel = self.viewModel,
            let header = viewModel.header,
            let headerButton = viewModel.headerButton,
            let url = URL(string: headerButton.url)
        else {
            return
        }

        self.presenter?.bannerButtonClicked(
            url: headerButton.url,
            text: headerButton.text,
            img: header.imagePath ?? "",
            type: "img"
        )

        UIApplication.shared.open(url, options: [:])
    }
}

extension HomeVerticalContainerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let view = stackView.arrangedSubviews[safe: 0] {
            let position = view.convert(
                CGPoint(x: 0.0, y: view.frame.maxY), to: nil
            )
            presenter?.viewDidScroll(yOffset: position.y)
        }

        scrollView.bounces = scrollView.contentOffset.y > 100
    }
}
