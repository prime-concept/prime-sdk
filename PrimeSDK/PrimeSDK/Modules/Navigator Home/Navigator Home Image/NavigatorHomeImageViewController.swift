import Foundation

protocol NavigatorHomeImageViewProtocol: AnyObject {
    func set(viewModel: NavigatorHomeImageViewModel)
    var viewController: UIViewController { get }
}

class NavigatorHomeImageViewController: UIViewController, NavigatorHomeImageViewProtocol {
    var presenter: NavigatorHomeImagePresenterProtocol?

    var tileHeightConstraint: NSLayoutConstraint?

    lazy var tileView: CenterTextTileView = {
        let tileView: CenterTextTileView = .fromNib()
        tileView.cornerRadius = 10
        self.view.addSubview(tileView)
        tileView.translatesAutoresizingMaskIntoConstraints = false

        // Use paddings instead of spacing between cells to show shadow
        tileView.topAnchor.constraint(
            equalTo: self.view.topAnchor,
            constant: 5
        ).isActive = true
        tileView.bottomAnchor.constraint(
            equalTo: self.view.bottomAnchor,
            constant: -10
        ).isActive = true
        tileView.leadingAnchor.constraint(
            equalTo: self.view.leadingAnchor,
            constant: 15
        ).isActive = true
        tileView.trailingAnchor.constraint(
            equalTo: self.view.trailingAnchor,
            constant: -15
        ).isActive = true

        return tileView
    }()

    convenience init() {
        self.init(nibName: "NavigatorHomeImageViewController", bundle: .primeSdk)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.view.addGestureRecognizer(tapGesture)

        presenter?.refresh()
    }

    @objc
    func onTap() {
        presenter?.didTap()
    }

    func set(viewModel: NavigatorHomeImageViewModel) {
        tileView.color = .black
        tileView.title = viewModel.title
        if let url = viewModel.imageURL {
            tileView.loadImage(from: url)
        }
        tileView.hidesSubtitle = true
        if tileHeightConstraint == nil {
            tileHeightConstraint = tileView.heightAnchor.constraint(equalToConstant: CGFloat(viewModel.height))
            tileHeightConstraint?.isActive = true
        } else {
            tileHeightConstraint?.constant = CGFloat(viewModel.height)
        }
    }

    var viewController: UIViewController {
        return self
    }
}
