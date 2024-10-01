import AVKit
import Nuke
import UIKit

class MovieVideoHeaderView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imdbRatingTitleLabel: UILabel!
    @IBOutlet weak var imdbRatingLabel: UILabel!
    @IBOutlet weak var bottomTextLabel: UILabel!
    @IBOutlet weak var closeButton: DetailCloseButton!
    @IBOutlet weak var playPauseButton: DetailCloseButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var gradientContainerView: GradientContainerView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardSubtitleLabel: UILabel!
    @IBOutlet weak var cardTitleLabel: UILabel!

    @IBOutlet weak var imageTopTextVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var topTextTitleVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleIMDBVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var imdbLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imdbBottomTextVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextHeightConstraint: NSLayoutConstraint!

    private let estimatedImageHeight: CGFloat = 225

    private var skeletonView: MovieVideoHeaderSkeletonView = .fromNib()

    let cardViewCornerRadius: CGFloat = 5.0

    var onClose: (() -> Void)?
    var openVideoController: ((AVPlayerViewController?) -> Void)?

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
            skeletonView.isUserInteractionEnabled = false
        }
    }

    private func setupFonts() {
        self.topTextLabel.font = UIFont.font(of: 14, weight: .medium)
        self.titleLabel.font = UIFont.font(of: 25, weight: .bold)
        self.imdbRatingLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.bottomTextLabel.font = UIFont.font(of: 16, weight: .regular)
        self.imdbRatingTitleLabel.font = UIFont.font(of: 10, weight: .bold)
        self.cardSubtitleLabel.font = UIFont.font(of: 6, weight: .regular)
        self.cardTitleLabel.font = UIFont.font(of: 10, weight: .regular)
    }

    private func setElements(hidden: Bool) {
        imageView.isHidden = hidden
        topTextLabel.isHidden = hidden
        titleLabel.isHidden = hidden
        imdbRatingLabel.isHidden = hidden
        bottomTextLabel.isHidden = hidden
        gradientContainerView.isHidden = hidden
        cardView.isHidden = hidden
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addSubview(skeletonView)
        skeletonView.alignToSuperview()
        isSkeletonShown = false

        setupConstraints()
        setupGradient()
        closeButton.image = UIImage(
            named: "player_close",
            in: .primeSdk,
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)

        playPauseButton.image = UIImage(
            named: "player_play",
            in: .primeSdk,
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)

        self.setupFonts()

        self.cardView.layer.cornerRadius = cardViewCornerRadius
        self.cardView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var topText: String? {
        didSet {
            topTextLabel.text = topText
        }
    }

    var imdbRating: Float? {
        didSet {
            imdbRatingLabel.isHidden = imdbRating == nil
            imdbLabelHeightConstraint.constant = imdbRating == nil ? 0 : 14
            titleIMDBVerticalConstraint.constant = imdbRating == nil ? 0 : 8
            imdbRatingLabel.text = String(format: "%.1f", imdbRating ?? 0)
        }
    }

    var imagePath: String? {
        didSet {
            if
                let imagePath = imagePath,
                let imageURL = URL(string: imagePath)
            {
                loadImage(from: imageURL)
            }
        }
    }

    var bottomText: String? {
        didSet {
            bottomTextLabel.text = bottomText
        }
    }

    var canSalePushkinCard: Bool = false {
        didSet {
            cardView.isHidden = canSalePushkinCard == false
        }
    }

    private var textColor: UIColor = .black {
        didSet {
            titleLabel?.textColor = textColor
            topTextLabel?.textColor = textColor.withAlphaComponent(0.5)
            bottomTextLabel?.textColor = textColor.withAlphaComponent(0.5)
            imdbRatingLabel?.textColor = textColor
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = backgroundColor ?? .white
            textColor = color.isLight() ? .black : .white
            videoView?.backgroundColor = color
            setupGradient()
        }
    }

    var videoPath: String?
    var player: AVPlayer?
    var playerController: AVPlayerViewController?

    private func loadImage(from url: URL) {
        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions.cacheOptions,
            into: imageView,
            completion: nil
        )
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        onClose?()
    }

    @IBAction func playPauseButtonPressed(_ sender: Any) {
        guard
            let videoPath = videoPath,
            let url = URL(string: videoPath)
        else {
            return
        }
        if playerController == nil {
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)

            let playerController = AVPlayerViewController()
            playerController.player = player
            self.playerController = playerController
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
        }

        openVideoController?(playerController)
    }

    func set(viewModel: DetailMovieHeaderViewModel) {
        title = viewModel.title
        topText = viewModel.subtitle
        bottomText = viewModel.bottomText
        imagePath = viewModel.imagePath
        imdbRating = viewModel.imdbRating
        videoPath = viewModel.trailerPath
        backgroundColor = viewModel.backgroundColor
        canSalePushkinCard = viewModel.canSalePushkinCard
    }

    private func setupConstraints() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        closeButton.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: 6 + statusBarHeight
        ).isActive = true
    }

    private func setupGradient() {
        let backgroundColor: UIColor = self.backgroundColor ?? .white

        gradientContainerView?.colors = [
            backgroundColor.withAlphaComponent(0.0).cgColor,
            backgroundColor.withAlphaComponent(0.0).cgColor,
            backgroundColor.withAlphaComponent(1).cgColor
        ]
    }

    var estimatedHeight: CGFloat {
        let sum1 = imageTopTextVerticalConstraint.constant + topTextLabelHeight.constant +
            topTextTitleVerticalConstraint.constant + titleIMDBVerticalConstraint.constant
        let sum2 = imdbLabelHeightConstraint.constant + imdbBottomTextVerticalConstraint.constant +
            bottomTextHeightConstraint.constant
        var titleHeight: CGFloat = 30
        if let title = title {
            titleHeight = title.height(withConstrainedWidth: UIScreen.main.bounds.width - 30, font: titleLabel.font)
        }
        return sum1 + sum2 + estimatedImageHeight + titleHeight
    }
}
