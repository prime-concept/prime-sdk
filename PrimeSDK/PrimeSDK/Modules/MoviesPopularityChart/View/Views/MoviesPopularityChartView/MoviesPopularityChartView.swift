import Nuke
import UIKit

struct MoviesPopularityChartConfig {
    let fillColor: UIColor
    let imageRadius: CGFloat

    static let `default` = MoviesPopularityChartConfig(
        fillColor: UIColor(red: 0.762, green: 0.854, blue: 0.962, alpha: 0.25),
        imageRadius: 4
    )
}

class MoviesPopularityChartView: BaseTileView, NibLoadable, ViewReusable {
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var containerView: UIView!

    var viewModel: MoviesPopularityChartItemViewModel?
    var config: MoviesPopularityChartConfig?

    var isSkeletonShown: Bool = false {
        didSet {
            [
                genresLabel,
                titleLabel,
                imageView
            ].forEach {
                isSkeletonShown ? $0?.showAnimatedGradientSkeleton() : $0?.hideSkeleton()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.needsGradient = false
        self.color = .clear
        self.imageView.clipsToBounds = true
        self.setupFonts()
    }

    private func setupFonts() {
        self.genresLabel.font = UIFont.font(of: 10, weight: .semibold)
        self.titleLabel.font = UIFont.font(of: 18, weight: .bold)
    }

    private func update() {
        guard let config = config, let viewModel = viewModel else {
            return
        }

        self.imageView.layer.cornerRadius = config.imageRadius
        self.genresLabel.text = viewModel.genresString
        self.titleLabel.text = viewModel.title

        var percent: CGFloat = 0
        let looked = CGFloat(viewModel.countLooked)
        let total = CGFloat(viewModel.countLookedTotal)

        if total > 0 {
            percent = looked / total
        }

        let fillLayer = CALayer()
        fillLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: containerView.frame.width * percent,
            height: containerView.frame.height
        )
        fillLayer.backgroundColor = config.fillColor.cgColor
        fillLayer.cornerRadius = config.imageRadius
        containerView.layer.addSublayer(fillLayer)

        loadImage(path: viewModel.imagePath)
    }

    private func loadImage(path: String) {
        if let url = URL(string: path) {
            loadImage(url: url)
        }
    }

    private func loadImage(url: URL) {
        var options = ImageLoadingOptions.cacheOptions
        options.placeholder = UIImage(named: "home-movie-placeholder", in: .primeSdk, compatibleWith: nil)
        Nuke.loadImage(
            with: url,
            options: options,
            into: imageView,
            completion: nil
        )
    }

    func setup(
        viewModel: MoviesPopularityChartItemViewModel,
        config: MoviesPopularityChartConfig
    ) {
        self.viewModel = viewModel
        self.config = config
        update()
    }

    func reset() {
        self.titleLabel.text = nil
        self.genresLabel.text = nil
        self.imageView.image = nil
    }
}
