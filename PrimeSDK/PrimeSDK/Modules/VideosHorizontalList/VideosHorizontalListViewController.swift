import SnapKit
import UIKit

protocol VideosHorizontalListViewProtocol: class {
    func update(viewModel: VideosHorizontalListViewModel)
    func updateVideos(viewModel: VideosHorizontalListViewModel)
    func updateQuizBanner(viewModel: QuizBannerViewModel?)
    func setLoading(isLoading: Bool)
}

class VideosHorizontalListViewController: UIViewController, VideosHorizontalListViewProtocol {
    var presenter: VideosHorizontalListPresenter?
    var viewModel: VideosHorizontalListViewModel?

    private var currentBlocks: [VideosHorizontalBlockModule] = []
    private var pageIndex = 0 {
        didSet {
            if pageIndex != oldValue {
                updatePlayStatus()
            }
        }
    }

    private var isLoading = false
    private var isQuizBannerShown = false
    private var quizBannerView: QuizBannerView?

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.clipsToBounds = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 20, weight: .bold)
        label.textColor = .black
        return label
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .horizontal
        stackView.spacing = 6
        return stackView
    }()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        [
            self.titleLabel,
            self.scrollView
        ].forEach(view.addSubview)

        [
            self.stackView
        ].forEach(scrollView.addSubview)

        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(24)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
        }

        self.scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(300)
            make.bottom.equalToSuperview().offset(-8)
        }

        self.stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-3)
            make.trailing.equalToSuperview().offset(3)
            make.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
        }

        self.view = view
    }

    func setLoading(isLoading: Bool) {
        self.isLoading = isLoading
        if isLoading, let viewModel = self.presenter?.loadingViewModel {
            self.update(viewModel: viewModel)
        }
    }

    func reload(blocks: [VideosHorizontalBlockModule]) {
        self.children.forEach({ $0.removeFromParent() })
        var controllers: [YoutubeVideoBlockViewController] = []
        let views: [UIView] = blocks.map { block in
            switch block {
            case .view(let view):
                return view
            case .viewController(let viewController):
                if let controller = viewController as? YoutubeVideoBlockViewController {
                    controllers.append(controller)
                }
                addChild(viewController)
                return viewController.view
            }
        }

        self.currentBlocks = blocks

        stackView.removeAllArrangedSubviews()
        let leftPlaceholderView = UIView()
        leftPlaceholderView.snp.makeConstraints { make in
            make.width.equalTo(0)
        }
        let rightPlaceholderView = UIView()
        rightPlaceholderView.snp.makeConstraints { make in
            make.width.equalTo(0)
        }
        stackView.addArrangedSubview(leftPlaceholderView)

        if let quizBannerView = quizBannerView {
            stackView.insertArrangedSubview(quizBannerView, at: 1)
        }

        for view in views {
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.width.equalTo(UIScreen.main.bounds.size.width - 30)
            }
        }
        self.stackView.addArrangedSubview(rightPlaceholderView)
        self.view.layoutIfNeeded()
        self.updatePlayStatus()

        controllers.forEach { $0.isSkeletonShown = self.isLoading }
    }

    func updateQuizBanner(viewModel: QuizBannerViewModel?) {
        func removeOldQuiz() {
            if let oldQuizView = self.quizBannerView {
                self.stackView.removeArrangedSubview(oldQuizView)
                oldQuizView.isHidden = true
                oldQuizView.removeFromSuperview()
            }
        }

        guard let viewModel = viewModel else {
            removeOldQuiz()
            return
        }

        let viewModule = viewModel.makeModule()
        switch viewModule {
        case .view(let view):
            removeOldQuiz()
            self.stackView.insertArrangedSubview(view, at: 1)
            view.snp.makeConstraints { make in
                make.width.equalTo(UIScreen.main.bounds.size.width - 30)
            }
            if let view = view as? QuizBannerView {
                view.didTapBlock = { [weak self] id in
                    self?.presenter?.didTapQuiz(id: id)
                }
                self.quizBannerView = view
            }

            self.isQuizBannerShown = true
        default:
            break
        }
        self.view.layoutIfNeeded()
        updatePlayStatus()
    }

    func updateVideos(viewModel: VideosHorizontalListViewModel) {
        self.viewModel = viewModel
        let youtubeSubviewViewModels = viewModel.subviews.compactMap { $0 as? YoutubeVideoBlockViewModel }
        let youtubeSubviews = currentBlocks.compactMap { block -> YoutubeVideoBlockViewController? in
            switch block {
            case .view:
                return nil
            case .viewController(let viewController):
                return viewController as? YoutubeVideoBlockViewController
            }
        }
        for subview in youtubeSubviews {
            if
                let id = subview.viewModel?.id,
                let viewModel = youtubeSubviewViewModels.first(where: { $0.id == id }) {
                subview.viewModel = viewModel
            }
        }
    }

    func update(viewModel: VideosHorizontalListViewModel) {
        guard viewModel.height > 0 else {
            self.view.isHidden = true
            self.removeFromParent()
            return
        }

        self.viewModel = viewModel
        scrollView.snp.updateConstraints { make in
            make.height.equalTo(viewModel.height)
        }

        if let title = viewModel.title {
            scrollView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
            }
            titleLabel.text = title
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
            scrollView.snp.makeConstraints { make in
                if let topInset = viewModel.topInset {
                    make.top.equalToSuperview().offset(topInset)
                } else {
                    make.top.equalToSuperview()
                }
            }
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        reload(
            blocks: viewModel.subviews.compactMap {
                $0.makeModule()
            }
        )
    }

    private func updatePlayStatus() {
        let youtubeSubviews = currentBlocks.enumerated().compactMap {
            index, block -> (index: Int, controller: YoutubeVideoBlockViewController)? in
            switch block {
            case .view:
                return nil
            case .viewController(let viewController):
                if let viewController = viewController as? YoutubeVideoBlockViewController {
                    return (index, viewController)
                } else {
                    return nil
                }
            }
        }

        for subview in youtubeSubviews {
            if pageIndex - (isQuizBannerShown ? 1 : 0) == subview.index {
                subview.controller.playVideo()
            } else {
                subview.controller.pauseVideo()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewModel = self.viewModel, !viewModel.subviews.isEmpty {
            update(viewModel: viewModel)
        } else {
            presenter?.reload()
        }
    }
}

enum VideosHorizontalBlockModule {
    case view(UIView)
    case viewController(UIViewController)
}

extension VideosHorizontalListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageIndex = scrollView.currentPage
    }
}

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.frame.size.width)) / self.frame.width)
    }
}
