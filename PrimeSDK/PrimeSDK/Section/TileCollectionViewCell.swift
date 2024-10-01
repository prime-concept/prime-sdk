import UIKit

class AnyUpdatableCollectionViewCell<ViewModel>: UICollectionViewCell {
    var isSkeletonShown: Bool = false
    // swiftlint:disable:next unavailable_function
    func update(with viewModel: ViewModel) {
        fatalError("Implement in subclass")
    }
}

class TileCollectionViewCell<T: BaseTileView, ViewModel>: AnyUpdatableCollectionViewCell<ViewModel>, ViewHighlightable {
    var topAnchorConstant: CGFloat { return 5 }
    var bottomAnchorConstant: CGFloat { return -10 }
    var leadingAnchorConstant: CGFloat { return 7.5 }
    var trailingAnchorConstant: CGFloat { return -7.5 }

    lazy var tileView: T = {
        let view: T = .fromNib()
        view.cornerRadius = 10
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        // Use paddings instead of spacing between cells to show shadow
        view.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: needsShadow ? topAnchorConstant : 0
        ).isActive = true
        view.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: needsShadow ? bottomAnchorConstant : 0
        ).isActive = true
        view.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: needsShadow ? leadingAnchorConstant : 0
        ).isActive = true
        view.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: needsShadow ? trailingAnchorConstant : 0
        ).isActive = true

        view.showShadow = needsShadow
        return view
    }()

    var needsShadow: Bool {
        return true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTile()
    }

    func highlight() {
        animate(isHighlighted: true)
    }

    func unhighlight() {
        animate(isHighlighted: false)
    }

    func resetTile() {
    }

    private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)? = nil) {
        if isHighlighted {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                animations: {
                    self.tileView.transform = .init(
                        scaleX: 0.95,
                        y: 0.95
                    )
                },
                completion: completion
            )
        } else {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                animations: {
                    self.tileView.transform = .identity
                },
                completion: completion
            )
        }
    }
}
