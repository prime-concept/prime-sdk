import Foundation
import Nuke

class MovieFriendsLikesView: UIView {
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: KinohodFlatDetailButton!
    @IBOutlet weak var shareButton: KinohodFlatDetailButton!
    @IBOutlet weak var titleLeftSpacingConstraint: NSLayoutConstraint!

    var viewModel: MovieFriendsLikesViewModel?

    var apiService: APIServiceProtocol?

    var sharingService: SharingServiceProtocol?
    weak var sharingSource: UIViewController?

    private let entityType = "movie"

    //swiftlint:disable force_unwrapping
    lazy var placeholderImages: [UIImage] = {
        let sequence = 1 ... 50
        let shuffledSequence = sequence.shuffled()

        return [
            UIImage(named: "\(shuffledSequence[0])", in: .primeSdk, compatibleWith: nil)!,
            UIImage(named: "\(shuffledSequence[1])", in: .primeSdk, compatibleWith: nil)!,
            UIImage(named: "\(shuffledSequence[2])", in: .primeSdk, compatibleWith: nil)!
        ]
    }()
    //swiftlint:enable force_unwrapping

    private var skeletonView: MovieFriendsLikesSkeletonView = .fromNib()
    private var themeProvider: ThemeProvider?

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
        titleLabel.isHidden = hidden
        likeButton.isHidden = hidden
        shareButton.isHidden = hidden
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 14, weight: .medium)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addSubview(skeletonView)
        self.skeletonView.alignToSuperview()
        self.isSkeletonShown = false

        self.initImageViews()

        self.registerForNotifications()
        self.setupFonts()
        self.themeProvider = ThemeProvider(themeUpdatable: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
            viewModel?.isFavorite = isFavoriteNow
        }
    }

    private func initImageViews() {
        let backgroundColor = self.backgroundColor ?? .white

        firstImageView?.layer.borderColor = backgroundColor.cgColor
        firstImageView?.layer.borderWidth = 3.0

        secondImageView?.layer.borderColor = backgroundColor.cgColor
        secondImageView?.layer.borderWidth = 3.0

        thirdImageView?.layer.borderColor = backgroundColor.cgColor
        thirdImageView?.layer.borderWidth = 3.0
    }

    private func setImageViews(hidden: Bool) {
        firstImageView.isHidden = hidden
        secondImageView.isHidden = hidden
        thirdImageView.isHidden = hidden
    }

    private var textColor: UIColor = .black {
        didSet {
            titleLabel?.textColor = textColor
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = backgroundColor ?? .white
            textColor = color.isLight() ? .black : .white
            likeButton?.isLightBackground = color.isLight()
            shareButton?.isLightBackground = color.isLight()
            initImageViews()
        }
    }

    var viewCount: Int? {
        didSet {
            if
                let viewCount = viewCount,
                viewCount > 0
            {
                let liked = NSLocalizedString("LikedCount", bundle: .primeSdk, comment: "")
                titleLabel.text = "\(viewCount) \(liked)"
                titleLabel.isHidden = false
                setImageViews(hidden: false)
                titleLeftSpacingConstraint.constant = 102
            } else {
                titleLabel.text = NSLocalizedString("ShareWithFriends", bundle: .primeSdk, comment: "")
                titleLabel.isHidden = false
                setImageViews(hidden: true)
                titleLeftSpacingConstraint.constant = 15
            }
        }
    }

    var isFavorite: Bool = false {
        didSet {
            likeButton.isSelected = isFavorite
        }
    }

    func setup(viewModel: MovieFriendsLikesViewModel) {
        self.viewModel = viewModel
        self.sharingService = SharingService(sdkManager: viewModel.sdkManager)

        self.viewCount = viewModel.viewCount
        self.isFavorite = viewModel.isFavorite
        self.backgroundColor = viewModel.backgroundColor

        load()
    }

    private func load() {
        guard
            let loadAction = viewModel?.loadAction,
            let sdkManager = viewModel?.sdkManager,
            let viewModel = viewModel
        else {
            return
        }

        loadAction.request.inject(action: loadAction.name, viewModel: viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: viewModel)

        apiService?.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done { [weak self] deserializedViewMap in
            guard let self = self else {
                return
            }

            self.viewModel?.initFriends(valueForAttributeID: deserializedViewMap.valueForAttributeID)
            self.updateFriendsViews()
        }.catch { [weak self] _ in
            self?.updateFriendsViews()
        }
    }

    private func updateFriendsViews() {
        guard let friends = viewModel?.friends else {
            return
        }

        switch friends.count {
        case 0:
            firstImageView.image = placeholderImages[0]
            secondImageView.image = placeholderImages[1]
            thirdImageView.image = placeholderImages[2]
        case 1:
            loadImage(path: friends[0].imagePath, imageView: firstImageView)
            secondImageView.image = placeholderImages[0]
            thirdImageView.image = placeholderImages[1]
        case 2:
            loadImage(path: friends[0].imagePath, imageView: firstImageView)
            loadImage(path: friends[1].imagePath, imageView: secondImageView)
            thirdImageView.image = placeholderImages[2]
        default:
            loadImage(path: friends[0].imagePath, imageView: firstImageView)
            loadImage(path: friends[1].imagePath, imageView: secondImageView)
            loadImage(path: friends[2].imagePath, imageView: thirdImageView)
        }
    }

    @IBAction func likePressed(_ sender: Any) {
        addToFavorites()
    }

    func addToFavorites() {
        guard
            let favoriteAction = viewModel?.favoriteAction,
            let id = viewModel?.id,
            let sdkManager = viewModel?.sdkManager
        else {
            return
        }

        let entityType = self.entityType
        let targetState = !isFavorite

        DataStorage.shared.set(value: targetState, for: "target_state", in: favoriteAction.name)
        DataStorage.shared.set(
            value: targetState ? "post" : "delete",
            for: "method_type",
            in: favoriteAction.name
        )

        favoriteAction.request.inject(action: favoriteAction.name, viewModel: viewModel)
        favoriteAction.response.inject(action: favoriteAction.name, viewModel: viewModel)

        sdkManager.analyticsDelegate?.favoriteToggle(
            isFavorite: targetState,
            entityName: "movie",
            id: id,
            source: nil
        )

        apiService?.request(
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

    @IBAction func sharePressed(_ sender: Any) {
        share()
    }

    private func share() {
        guard
            let viewModel = viewModel,
            let shareAction = viewModel.shareAction,
            let source = sharingSource
        else {
            return
        }

        sharingService?.share(
            action: shareAction,
            viewModel: viewModel,
            viewController: source
        )
    }

    private func loadImage(path: String, imageView: UIImageView) {
        if let url = URL(string: path) {
            loadImage(url: url, imageView: imageView)
        }
    }

    private func loadImage(url: URL, imageView: UIImageView) {
        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions.cacheOptions,
            into: imageView,
            completion: nil
        )
    }
}

extension MovieFriendsLikesView: ThemeUpdatable {
    func update(with theme: Theme) {
        self.likeButton.setImage(theme.imageSet.cinemaTileFavoriteNormal, for: .normal)
        self.likeButton.setImage(theme.imageSet.cinemaTileFavoriteSelected, for: .selected)
    }
}
