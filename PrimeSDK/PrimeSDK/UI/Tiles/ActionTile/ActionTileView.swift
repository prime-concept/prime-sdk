import UIKit

class ActionTileView: ImageTileView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var leftTopLabel: PaddingLabel!
    @IBOutlet private weak var blurView: UIView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var addButton: AddButton!

    private var apiService = APIService()
    private var sharingService: SharingServiceProtocol?

    private var diagonalRecommendedBadgeView: DiagonalRecommendedBadgeView?
    private var isInit = false

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var titleColor: UIColor? {
        didSet {
            titleLabel.textColor = titleColor
        }
    }

    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
        }
    }

    var leftTopText: String? {
        didSet {
            blurView.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.text = leftTopText
        }
    }

    var shouldShowRecommendedBadge: Bool = false {
        didSet {
            diagonalRecommendedBadgeView?.isHidden = !shouldShowRecommendedBadge
        }
    }

    var isFavoriteButtonHidden: Bool = true {
        didSet {
            addButton.isHidden = isFavoriteButtonHidden
        }
    }

    var isFavoriteButtonSelected: Bool = false {
        didSet {
            addButton.isSelected = isFavoriteButtonSelected
        }
    }

    var isShareButtonHidden: Bool = true {
        didSet {
            shareButton.isHidden = isShareButtonHidden
        }
    }

    var viewModel: ListItemViewModel? {
        didSet {
            guard let sdkManager = self.viewModel?.sdkManager else {
                return
            }

            self.sharingService = SharingService(sdkManager: sdkManager)
        }
    }

    weak var sharingSource: UIViewController?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupFonts()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !self.isInit {
            self.isInit = true

            self.initDiagonalBadge()

            self.shareButton.setImage(
                UIImage(named: "share", in: .primeSdk, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
                for: .normal
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.handleChangedFavorites(notification:)),
                name: .itemFavoriteChanged,
                object: nil
            )
        }
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 16, weight: .semibold)
        self.leftTopLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.subtitleLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.addButton.titleLabel?.font = UIFont.font(of: 18)
        self.shareButton.titleLabel?.font = UIFont.font(of: 18)
    }

    private func initDiagonalBadge() {
        let badgeView = DiagonalRecommendedBadgeView()
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.isHidden = !shouldShowRecommendedBadge

        self.addSubview(badgeView)
        badgeView.heightAnchor.constraint(
            equalToConstant: 62
            ).isActive = true
        badgeView.widthAnchor.constraint(
            equalToConstant: 62
            ).isActive = true
        badgeView.topAnchor.constraint(
            equalTo: self.topAnchor
            ).isActive = true
        badgeView.rightAnchor.constraint(
            equalTo: self.rightAnchor
            ).isActive = true

        self.diagonalRecommendedBadgeView = badgeView
    }

    @objc
    private func handleChangedFavorites(notification: Notification) {
        guard
            let entityType = notification.userInfo?[Favorites.notificationItemEntityTypeKey] as? String,
            let id = notification.userInfo?[Favorites.notificationItemIDKey] as? String,
            let isFavorite = notification.userInfo?[Favorites.notificationItemIsFavoriteNowKey] as? Bool
        else {
            return
        }

        let favoriteItem = FavoriteItem(id: id, entityType: entityType, isFavoriteNow: isFavorite)

        guard var viewModel = self.viewModel else {
            return
        }

        guard viewModel.id == id && viewModel.entityType == entityType else {
            return
        }

        if viewModel.isFavorite != favoriteItem.isFavoriteNow {
            viewModel.isFavorite = favoriteItem.isFavoriteNow

            self.viewModel = viewModel
            self.isFavoriteButtonSelected = viewModel.isFavorite
        }
    }

    func makeCopy() -> ActionTileView {
        let view: ActionTileView = .fromNib()
        view.title = title
        view.subtitle = subtitle
        view.leftTopText = leftTopText
        view.shouldShowRecommendedBadge = shouldShowRecommendedBadge
        view.backgroundImageView.image = backgroundImageView.image

        return view
    }

    @IBAction func onAddButtonClick(_ sender: Any) {
        guard let viewModel = self.viewModel,
            let favoriteAction = viewModel.favoriteAction,
            let sdkManager = viewModel.sdkManager
        else {
            return
        }

        let targetState = !viewModel.isFavorite

        DataStorage.shared.set(value: targetState, for: "target_state", in: favoriteAction.name)
        DataStorage.shared.set(
            value: targetState ? "post" : "delete",
            for: "method_type",
            in: favoriteAction.name
        )

        favoriteAction.request.inject(action: favoriteAction.name, viewModel: viewModel)
        favoriteAction.response.inject(action: favoriteAction.name, viewModel: viewModel)

        apiService.request(
            action: favoriteAction.name,
            configRequest: favoriteAction.request,
            configResponse: favoriteAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.done(on: .main) { _ in
            NotificationCenter.default.post(
                name: .itemFavoriteChanged,
                object: nil,
                userInfo: [
                    Favorites.notificationItemIDKey: viewModel.id,
                    Favorites.notificationItemIsFavoriteNowKey: targetState,
                    Favorites.notificationItemEntityTypeKey: viewModel.entityType
                ]
            )
        }.cauterize()
    }

    @IBAction func onShareButtonClick(_ sender: Any) {
        guard let viewModel = self.viewModel, let shareAction = viewModel.shareAction else {
            return
        }

        sharingService?.share(
            action: shareAction,
            viewModel: viewModel,
            viewController: self.sharingSource
        )
    }
}
