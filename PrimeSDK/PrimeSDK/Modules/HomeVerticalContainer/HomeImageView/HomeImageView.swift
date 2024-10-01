import Nuke
import UIKit

class HomeImageView: UIView, NibLoadable, ViewReusable {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var gradientView: GradientContainerView!
    @IBOutlet weak var gradientHeightConstraint: NSLayoutConstraint!

    var path: String? {
        didSet {
            if let path = path {
                loadImage(path: path)
            }
        }
    }

    var height: CGFloat = .leastNonzeroMagnitude {
        didSet {
            imageViewHeight?.constant = height
        }
    }

    var gradientHeight: CGFloat = .leastNonzeroMagnitude {
        didSet {
            gradientHeightConstraint.constant = gradientHeight
        }
    }

    private func loadImage(path: String) {
        if let url = URL(string: path) {
            loadImage(url: url)
        }
    }

    private func loadImage(url: URL) {
        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions.cacheOptions,
            into: imageView,
            completion: nil
        )
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        if #available(iOS 11, *) {
            height = .leastNonzeroMagnitude
            gradientHeight = .leastNonzeroMagnitude
        } else {
            height = 1.1
            gradientHeight = 1.1
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    func setup(viewModel: HomeImageViewModel) {
        self.path = viewModel.imagePath
        self.height = viewModel.imageHeight
        self.gradientHeight = viewModel.gradientHeight
        setupGradient()
    }

    func setupGradient() {
        gradientView.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.95).cgColor
        ]
    }
}
