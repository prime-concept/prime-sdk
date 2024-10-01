import Nuke
import SkeletonView
import UIKit

class HomeMoviePlainCard: BaseTileView, NibLoadable, ViewReusable {
    @IBOutlet weak var ratingBackgroundView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomTextGradientBackgroundView: GradientContainerView!
    @IBOutlet weak var bottomTextLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardImageView: UIImageView!

    @IBOutlet weak var cardTopToRatingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardTopToSuperViewConstraint: NSLayoutConstraint!

    let ratingCornerRadius: CGFloat = 5.0
    let imageViewCornerRadius: CGFloat = 8.0
    let cardViewCornerRadius: CGFloat = 5.0

    var skeletonView: HomeMoviePlainCardSkeletonView = .fromNib()

    var isSkeletonShown: Bool = false {
        didSet {
            skeletonView.translatesAutoresizingMaskIntoConstraints = false
            if isSkeletonShown {
                self.skeletonView.showAnimatedGradientSkeleton()
                setElements(hidden: true)
                self.skeletonView.isHidden = false
            } else {
                self.skeletonView.isHidden = true
                setElements(hidden: false)
                self.skeletonView.hideSkeleton()
            }
        }
    }

    private func setElements(hidden: Bool) {
        ratingBackgroundView.isHidden = hidden
        ratingLabel.isHidden = hidden
        imageView.isHidden = hidden
        genresLabel.isHidden = hidden
        titleLabel.isHidden = hidden
        bottomTextGradientBackgroundView.isHidden = isHidden
        bottomTextLabel.isHidden = isHidden
        cardView.isHidden = isHidden
    }

    private func setupFonts() {
        self.ratingLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.genresLabel.font = UIFont.font(of: 9, weight: .semibold)
        self.titleLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.bottomTextLabel.font = UIFont.font(of: 14, weight: .bold)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(skeletonView)
        skeletonView.alignToSuperview()
        isSkeletonShown = false

        self.ratingBackgroundView.layer.cornerRadius = ratingCornerRadius
        self.ratingBackgroundView.clipsToBounds = true
        self.cardView.layer.cornerRadius = cardViewCornerRadius
        self.cardView.clipsToBounds = true
        self.bottomTextGradientBackgroundView.layer.cornerRadius = imageViewCornerRadius
        self.bottomTextGradientBackgroundView.clipsToBounds = true
        self.bottomTextGradientBackgroundView.layer.masksToBounds = true

        self.needsGradient = false
        self.color = .clear
        self.imageView.layer.cornerRadius = imageViewCornerRadius
        self.imageView.clipsToBounds = true
        self.setupFonts()
    }

    private var viewModel: HomeMoviePlainCardViewModel? {
        didSet {
            if let viewModel = viewModel {
                if let imdbRating = viewModel.imdbRating {
                    self.cardTopToRatingConstraint.priority = .defaultHigh
                    self.cardTopToSuperViewConstraint.priority = .defaultLow

                    self.ratingBackgroundView.isHidden = false
                    self.ratingLabel.text = "IMDB \(String(format: "%.1f", imdbRating))"
                } else {
                    self.cardTopToRatingConstraint.priority = .defaultLow
                    self.cardTopToSuperViewConstraint.priority = .defaultHigh

                    self.ratingBackgroundView.isHidden = true
                    self.ratingLabel.text = ""
                }
                self.genresLabel.text = viewModel.genresString
                self.titleLabel.text = viewModel.title
                if let bottomText = viewModel.premiereDateString {
                    self.bottomTextLabel.text = bottomText
                    self.bottomTextGradientBackgroundView.colors = [
                        UIColor.black.withAlphaComponent(0),
                        UIColor.black.withAlphaComponent(0.8)
                    ].map { $0.cgColor }
                }
                loadImage(path: viewModel.imagePath)
                self.cardImageView.image = UIImage(named: "pushkin_card_icon", in: .primeSdk, compatibleWith: nil)
                self.cardView.isHidden = viewModel.canSalePushkinCard == false
                self.layoutIfNeeded()
            }
        }
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

    func setup(viewModel: HomeMoviePlainCardViewModel) {
        self.viewModel = viewModel
    }

    func reset() {
        self.titleLabel.text = ""
        self.genresLabel.text = ""
        self.ratingLabel.text = ""
        self.bottomTextLabel.text = ""
        self.bottomTextGradientBackgroundView.isHidden = true
        self.imageView.image = nil
        self.cardView.isHidden = true
    }
}
