import UIKit

protocol HorizontalListsContainerPresenterProtocol {
    func refresh()
    func horizontalItemPressed(list: String, position: Int)
}

class HorizontalListsContainerViewController: UIViewController, HorizontalListsContainerViewProtocol {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

    var bottomConstraint: NSLayoutConstraint?
    var topConstraint: NSLayoutConstraint?

    var presenter: HorizontalListsContainerPresenterProtocol?
    private var viewModel = HorizontalListsContainerViewModel()

    var subviews: [(name: String, view: DetailHorizontalCollectionView)] = []

    convenience init() {
        self.init(nibName: "HorizontalListsContainerViewController", bundle: .primeSdk)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.refresh()

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }

    func update(viewModel: HorizontalListsContainerViewModel) {
        self.viewModel = viewModel

        for subview in viewModel.subviews {
            if let subviewView = subviews.first(where: { $0.name == subview.viewName })?.view {
                if subview.items.isEmpty {
                    subviewView.removeFromSuperview()
                    if let index = subviews.firstIndex(where: { $0.name == subview.viewName }) {
                        subviews.remove(at: index)
                    }
                } else {
                    subviewView.set(items: subview.items)
                }
            } else {
                if let subviewView = DetailRow.horizontalItems.makeView(
                    from: subview
                ) as? DetailHorizontalCollectionView {
                   subviewView.onCellClick = { [weak self] horizontalItemViewModel in
                       guard let position = horizontalItemViewModel.position else {
                           return
                       }
                       self?.presenter?.horizontalItemPressed(
                           list: subview.viewName,
                           position: position
                       )
                    }

                    add(subview: subviewView, with: CGFloat((subview.itemHeight ?? 0) + 40))
                    subviews += [(name: subview.viewName, view: subviewView)]
                }
            }
        }
        scrollView.layoutIfNeeded()
    }

    var viewController: UIViewController {
        return self
    }

    private func add(subview: DetailHorizontalCollectionView, with height: CGFloat) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(subview)
        if let last = subviews.last?.view {
            let top = NSLayoutConstraint(
                item: subview,
                attribute: .top,
                relatedBy: .equal,
                toItem: last,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            )
            top.isActive = true
        } else {
            topConstraint?.isActive = false
            topConstraint = NSLayoutConstraint(
                item: subview,
                attribute: .top,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .top,
                multiplier: 1,
                constant: 0
            )
            topConstraint?.isActive = true
        }

        let left = NSLayoutConstraint(
            item: subview,
            attribute: .left,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .left,
            multiplier: 1,
            constant: 0
        )
        left.isActive = true

        let right = NSLayoutConstraint(
            item: subview,
            attribute: .right,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .right,
            multiplier: 1,
            constant: 0
        )
        right.isActive = true

        bottomConstraint?.isActive = false
        bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        bottomConstraint?.isActive = true

        let height = NSLayoutConstraint(
            item: subview,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: height
        )
        height.isActive = true
    }
}
