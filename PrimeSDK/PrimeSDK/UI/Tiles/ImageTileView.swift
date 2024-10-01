import Nuke
import UIKit

class ImageTileView: BaseTileView {
    var leadingOffset: CGFloat {
        return 0
    }

    var trailingOffset: CGFloat {
        return 0
    }

    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill

        self.insertSubview(imageView, at: 0)

        imageView.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: 0
        ).isActive = true
        imageView.bottomAnchor.constraint(
            equalTo: self.bottomAnchor,
            constant: 0
        ).isActive = true
        imageView.leadingAnchor.constraint(
            equalTo: self.leadingAnchor,
            constant: self.leadingOffset
        ).isActive = true
        imageView.trailingAnchor.constraint(
            equalTo: self.trailingAnchor,
            constant: self.trailingOffset
        ).isActive = true

        return imageView
    }()

    private lazy var dimView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white

        self.insertSubview(view, aboveSubview: self.backgroundImageView)

        view.topAnchor.constraint(
            equalTo: self.topAnchor
        ).isActive = true
        view.bottomAnchor.constraint(
            equalTo: self.bottomAnchor
        ).isActive = true
        view.leadingAnchor.constraint(
            equalTo: self.leadingAnchor
        ).isActive = true
        view.trailingAnchor.constraint(
            equalTo: self.trailingAnchor
        ).isActive = true
        view.isHidden = true
        return view
    }()

    func loadImage(from url: URL) {
        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions.cacheOptions,
            into: backgroundImageView,
            progress: nil
        ) { [weak self] response in
            self?.dimView.isHidden = (try? response.get().image) == nil
        }
    }

    override var color: UIColor {
        didSet {
            dimView.backgroundColor = color.withAlphaComponent(0.5)
            super.color = color
        }
    }

    override var cornerRadius: CGFloat {
        didSet {
            dimView.layer.cornerRadius = cornerRadius
            backgroundImageView.layer.cornerRadius = cornerRadius

            super.cornerRadius = cornerRadius
        }
    }
}
