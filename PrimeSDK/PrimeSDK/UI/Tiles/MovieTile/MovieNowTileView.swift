import Nuke
import UIKit

final class MovieNowTileView: BaseTileView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var IMDBRatingLabel: UILabel!
    @IBOutlet private weak var IMDBLabel: UILabel!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet weak var premiereLabel: UILabel!

    @IBOutlet weak var premierHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionToPremierConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleToIMDBVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelsVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var descriptionToIMDBVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pushkinCardLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pushkinCardToIMDBHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!

    @IBOutlet weak var imaxBadgeImageView: UIImageView!

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var labelsOriginalVerticalSpacing: CGFloat!
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var titleToIMDBOriginalVerticalSpacing: CGFloat!

    private var skeletonView: MovieNowTileSkeletonView = .fromNib()
    private var themeProvider: ThemeProvider?

    private let apiService = APIService()
    var viewModel: MovieNowViewModel?
    let entityType = "movie"

    var onFavoriteClick: ((Bool) -> Void)?

    var isSkeletonShown: Bool = false {
        didSet {
            self.skeletonView.translatesAutoresizingMaskIntoConstraints = false
            if self.isSkeletonShown {
                self.skeletonView.showAnimatedGradientSkeleton()
                self.setElements(hidden: true)
                self.skeletonView.isHidden = false
            } else {
                self.skeletonView.isHidden = true
                self.setElements(hidden: false)
                self.skeletonView.hideSkeleton()
            }
            self.skeletonView.isUserInteractionEnabled = false
        }
    }

    var genres: [String] = [] {
        didSet {
            let text = self.genres.first ?? ""
            self.genresLabel.text = text.uppercased()
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var IMDBRating: String? {
        didSet {
            guard let rating = self.IMDBRating, !rating.isEmpty else {
                self.IMDBLabel.isHidden = true
                self.IMDBRatingLabel.isHidden = true
                if self.cardView.isHidden {
                    self.descriptionToIMDBVerticalSpacingConstraint?.isActive = false
                    self.labelsVerticalSpacingConstraint?.constant = self.titleToIMDBOriginalVerticalSpacing
                } else {
                    self.pushkinCardToIMDBHorizontalConstraint.priority = .defaultLow
                    self.pushkinCardLeadingConstraint.priority = .defaultHigh
                }
                return
            }
            if !self.cardView.isHidden {
                self.pushkinCardToIMDBHorizontalConstraint.priority = .defaultHigh
                self.pushkinCardLeadingConstraint.priority = .defaultLow
            }
            self.IMDBLabel.isHidden = false
            self.IMDBRatingLabel.isHidden = false
            self.labelsVerticalSpacingConstraint?.constant = self.labelsOriginalVerticalSpacing
            self.descriptionToIMDBVerticalSpacingConstraint?.isActive = true
            self.IMDBRatingLabel.text = rating
        }
    }

    var canSalePushkinCard: Bool = false {
        didSet {
            self.cardView.isHidden = self.canSalePushkinCard == false
            if self.canSalePushkinCard {
                if self.IMDBLabel.isHidden {
                    self.pushkinCardToIMDBHorizontalConstraint.priority = .defaultLow
                    self.pushkinCardLeadingConstraint.priority = .defaultHigh
                } else {
                    self.pushkinCardToIMDBHorizontalConstraint.priority = .defaultHigh
                    self.pushkinCardLeadingConstraint.priority = .defaultLow
                }
                self.descriptionToIMDBVerticalSpacingConstraint?.isActive = true
                self.labelsVerticalSpacingConstraint?.constant = self.labelsOriginalVerticalSpacing
            } else {
                self.pushkinCardToIMDBHorizontalConstraint.priority = .defaultHigh
                self.pushkinCardLeadingConstraint.priority = .defaultLow
            }
        }
    }

    var descriptionText: String? {
        didSet {
            self.descriptionLabel.text = self.descriptionText
        }
    }

    var premierDate: Date? {
        didSet {
            guard let date = self.premierDate else {
                self.premierHeightConstraint.constant = 0
                self.descriptionToPremierConstraint.constant = 0
                return
            }
            self.premierHeightConstraint.constant = 15
            self.descriptionToPremierConstraint.constant = 5

            let dateString = FormatterHelper.formatDateOnlyDayAndMonth(date)
            self.premiereLabel.text = "\(NSLocalizedString("Premiere", bundle: .primeSdk, comment: "")) \(dateString)"
        }
    }

    var isFavorite: Bool = false {
        didSet {
            self.favoriteButton.isSelected = self.isFavorite
        }
    }

    // MARK: - Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addSubview(self.skeletonView)
        self.skeletonView.alignToSuperview()
        self.isSkeletonShown = false

        self.color = .clear
        self.labelsOriginalVerticalSpacing = self.labelsVerticalSpacingConstraint.constant
        self.titleToIMDBOriginalVerticalSpacing = self.titleToIMDBVerticalSpacingConstraint.constant
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 8.0
        self.cardView.layer.cornerRadius = 2.0
        self.registerForNotifications()
        self.setupFonts()
        self.themeProvider = ThemeProvider(themeUpdatable: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public methods

    func loadImage(from url: URL) {
        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions.cacheOptions,
            into: self.imageView,
            completion: nil
        )
    }

    func setup(viewModel: MovieNowViewModel) {
        self.genres = viewModel.genres
        self.title = viewModel.title
        self.IMDBRating = viewModel.IMDBRating
        self.descriptionText = viewModel.descriptionText
        self.favoriteButton.isHidden = viewModel.favoriteAction == nil
        self.isFavorite = viewModel.isFavorite
        if let imagePath = viewModel.imagePath,
            let url = URL(string: imagePath) {
            self.loadImage(from: url)
        }
        self.viewModel = viewModel
        self.imaxBadgeImageView.isHidden = !viewModel.isIMax
        self.premierDate = viewModel.premiereDate
        self.canSalePushkinCard = viewModel.canSalePushkinCard
    }

    func addToFavorites() {
        guard
            let favoriteAction = self.viewModel?.favoriteAction,
            let id = self.viewModel?.id,
            let sdkManager = self.viewModel?.sdkManager
        else {
            return
        }

        let entityType = self.entityType
        let targetState = !self.isFavorite

        DataStorage.shared.set(value: targetState, for: "target_state", in: favoriteAction.name)
        DataStorage.shared.set(
            value: targetState ? "post" : "delete",
            for: "method_type",
            in: favoriteAction.name
        )

        favoriteAction.request.inject(action: favoriteAction.name, viewModel: self.viewModel)
        favoriteAction.response.inject(action: favoriteAction.name, viewModel: self.viewModel)

        sdkManager.analyticsDelegate?.favoriteToggle(
            isFavorite: targetState,
            entityName: "movie",
            id: id,
            source: nil
        )

        self.apiService.request(
            action: favoriteAction.name,
            configRequest: favoriteAction.request,
            configResponse: favoriteAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { _ in
            NotificationCenter.default.post(
                name: .itemFavoriteChanged,
                object: nil,
                userInfo: [
                    Favorites.notificationItemIDKey: id,
                    Favorites.notificationItemIsFavoriteNowKey: targetState,
                    Favorites.notificationItemEntityTypeKey: entityType
                ]
            )
        }.cauterize()
    }

    @IBAction func didTapFavorite(_ sender: UIButton) {
        self.addToFavorites()
    }

    // MARK: - Helpers

    private func setupFonts() {
        self.genresLabel.font = UIFont.font(of: 10, weight: .semibold)
        self.titleLabel.font = UIFont.font(of: 14, weight: .bold)
        self.IMDBRatingLabel.font = UIFont.font(of: 12)
        self.IMDBLabel.font = UIFont.font(of: 10, weight: .bold)
        self.premiereLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.descriptionLabel.font = UIFont.font(of: 13)
        self.favoriteButton.titleLabel?.font = UIFont.font(of: 18)
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleChangedFavorites(notification:)),
            name: .itemFavoriteChanged,
            object: nil
        )
    }

    @objc
    private func handleChangedFavorites(notification: Notification) {
        guard
            let entityType = notification.userInfo?[Favorites.notificationItemEntityTypeKey] as? String,
            let id = notification.userInfo?[Favorites.notificationItemIDKey] as? String,
            let isFavoriteNow = notification.userInfo?[Favorites.notificationItemIsFavoriteNowKey] as? Bool
        else {
            return
        }

        if
            self.viewModel?.id == id && self.entityType == entityType &&
            self.isFavorite != isFavoriteNow
        {
            self.isFavorite = isFavoriteNow
            self.viewModel?.isFavorite = isFavoriteNow
        }
    }

    private func setElements(hidden: Bool) {
        self.imageView.isHidden = hidden
        self.genresLabel.isHidden = hidden
        self.titleLabel.isHidden = hidden
        self.IMDBRatingLabel.isHidden = self.viewModel?.IMDBRating == nil
        self.IMDBLabel.isHidden = self.viewModel?.IMDBRating == nil
        self.premiereLabel.isHidden = hidden
        self.descriptionLabel.isHidden = hidden
        self.favoriteButton.isHidden = hidden
        self.imaxBadgeImageView.isHidden = !(self.viewModel?.isIMax ?? false)
        self.cardView.isHidden = hidden

        if let rating = self.viewModel?.IMDBRating, !rating.isEmpty {
            self.IMDBRatingLabel.isHidden = false
            self.IMDBLabel.isHidden = false
        } else {
            self.IMDBRatingLabel.isHidden = true
            self.IMDBLabel.isHidden = true
        }

        if let canSale = self.viewModel?.canSalePushkinCard, canSale {
            self.cardView.isHidden = false
        } else {
            self.cardView.isHidden = true
        }
    }
}

extension MovieNowTileView: ThemeUpdatable {
    func update(with theme: Theme) {
        self.favoriteButton.setImage(theme.imageSet.cinemaTileFavoriteNormal, for: .normal)
        self.favoriteButton.setImage(theme.imageSet.cinemaTileFavoriteSelected, for: .selected)
    }
}
