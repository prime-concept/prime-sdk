import Foundation

protocol NavigatorHomeViewProtocol: class {
    func insert(block: HomeContainerBlockViewModelProtocol, atIndex: Int)
    func update(viewModel: NavigatorHomeViewModel)
    func updateInternetStatus(isReachable: Bool)
}

class NavigatorHomeViewController: UIViewController, NavigatorHomeViewProtocol {
    var presenter: NavigatorHomePresenterProtocol?

    var viewModel: NavigatorHomeViewModel?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!

    convenience init() {
        self.init(nibName: "NavigatorHomeViewController", bundle: .primeSdk)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.refresh()
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

    func reload(blocks: [(HomeBlockModule, NavigatorHomeElementWidth)]) {
        let views: [(view: UIView, isHalf: Bool)] = blocks.map { block in
            switch block.0 {
            case .view(let view):
                return (view, block.1 == .half)
            case .viewController(let viewController):
                addChild(viewController)
                return (viewController.view, block.1 == .half)
            }
        }

        stackView.removeAllArrangedSubviews()

        var currentWrapper: UIStackView?
        for view in views {
            if view.isHalf {
                if let wrapper = currentWrapper {
                    wrapper.addArrangedSubview(view.view)
                    currentWrapper = nil
                } else {
                    let wrapper = wrapInHorizontalStackView(view: view.view)
                    currentWrapper = wrapper
                    stackView.addArrangedSubview(wrapper)
                }
            } else {
                stackView.addArrangedSubview(view.0)
            }
        }
        self.view.layoutIfNeeded()
    }

    private func wrapInHorizontalStackView(view: UIView) -> UIStackView {
        let wrapper = UIStackView(arrangedSubviews: [view])
        wrapper.alignment = .fill
        wrapper.distribution = .fillEqually
        wrapper.axis = .horizontal
        wrapper.spacing = -15
        return wrapper
    }

    func updateInternetStatus(isReachable: Bool) {
//        noInternetView.isHidden = isReachable
    }

    func update(viewModel: NavigatorHomeViewModel) {
        self.viewModel = viewModel
        reload(
            blocks: viewModel.subviews.compactMap {
                if let module = $0.makeModule() {
                    return (module, $0.width)
                } else {
                    return nil
                }
            }
        )
    }
}
