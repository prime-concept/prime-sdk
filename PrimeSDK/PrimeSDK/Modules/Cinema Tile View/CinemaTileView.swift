// swiftlint:disable:next file_header
//THIS CLASS IS AN ABSOLUTE DISASTER AND AN ENORMOUSLY BAD DESIGN
//I HAD ONE DAY TO SETUP FUCKING FAVORITES ALL OVER THE APP

import Nuke
import SkeletonView
import UIKit

final class CinemaTileView: BaseTileView, NibLoadable {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var mallLabel: UILabel!
    @IBOutlet weak var subwayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var subwayColorView: UIView!

    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var showMapButton: UIButton!

    @IBOutlet weak var mallSubwayDistance: NSLayoutConstraint!
    @IBOutlet weak var addressDistanceDistance: NSLayoutConstraint!
    @IBOutlet weak var badgesContainerView: UIView!
    @IBOutlet weak var badgesContainerViewHeight: NSLayoutConstraint!

    private let entityType: String = "cinema"
    private let apiService = APIService()
    private var themeProvider: ThemeProvider?

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var mall: String? {
        didSet {
            mallLabel.text = mall
            if mall == nil || mall?.isEmpty == true {
                mallSubwayDistance.constant = 0
            } else {
                mallSubwayDistance.constant = 8
            }
        }
    }

    var subway: String? {
        didSet {
            subwayLabel.text = subway
        }
    }

    var address: String? {
        didSet {
            addressLabel.text = address
            if address == nil || address?.isEmpty == true {
                addressDistanceDistance.constant = 0
            } else {
                addressDistanceDistance.constant = 3
            }
        }
    }

    var distance: String? {
        didSet {
            if let distance = distance {
                distanceLabel.isHidden = false
                distanceLabel.text = distance
            } else {
                distanceLabel.isHidden = true
            }
        }
    }

    var subwayColor: UIColor? {
        didSet {
            subwayColorView.backgroundColor = subwayColor ?? UIColor.clear
        }
    }

    var isFavorite: Bool = false {
        didSet {
            favoriteButton.isSelected = isFavorite
        }
    }

    var hasBadges: Bool = false {
        didSet {
            badgesContainerViewHeight.constant = hasBadges ? 20 : 0
        }
    }

    var onFavoriteClick: (() -> Void)?

    var viewModel: CinemaCardViewModel?

    var skeletonView: CinemaTileSkeletonView = .fromNib()

    var isSkeletonShown: Bool = false {
        didSet {
            if isSkeletonShown {
                skeletonView.layer.cornerRadius = layer.cornerRadius
                skeletonView.clipsToBounds = true
                self.skeletonView.showAnimatedGradientSkeleton()
                self.skeletonView.isHidden = false
            } else {
                self.skeletonView.isHidden = true
                self.skeletonView.hideSkeleton()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(skeletonView)
        self.skeletonView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.registerForNotifications()
        self.setupFonts()
        self.themeProvider = ThemeProvider(themeUpdatable: self)
        self.isSkeletonShown = false
        self.registerForNotifications()
    }

    func setup(viewModel: CinemaCardViewModel) {
        title = viewModel.title
        subway = viewModel.subway?.name
        subwayColor = viewModel.subway?.color
        mall = viewModel.mall
        distance = viewModel.distanceString
        isFavorite = viewModel.isFavorite
        if distance != nil {
            address = viewModel.address + " ·"
        } else {
            address = viewModel.address
        }
        self.hasBadges = viewModel.hasBadge
        if hasBadges {
            addBadges(badges: viewModel.badges)
        }
        self.viewModel = viewModel
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 14, weight: .bold)
        self.mallLabel.font = UIFont.font(of: 12, weight: .medium)
        self.subwayLabel.font = UIFont.font(of: 12, weight: .medium)
        self.addressLabel.font = UIFont.font(of: 12, weight: .medium)
        self.distanceLabel.font = UIFont.font(of: 12, weight: .medium)
        self.favoriteButton.titleLabel?.font = UIFont.font(of: 18)
        self.showMapButton.titleLabel?.font = UIFont.font(of: 10, weight: .semibold)
    }

    private func addBadges(badges: [CinemaBadge]) {
        var lastBadge: UIView?

        for badge in badges {
            let badgeView = getBadge(
                badge: badge
            )
            let verticalConstraints = getVerticalConstraintsForBadge(
                badge: badge
            )

            badgesContainerView.addSubview(badgeView)
            badgeView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(verticalConstraints.top)
                make.bottom.equalToSuperview().offset(verticalConstraints.bottom)
                if let lastBadge = lastBadge {
                    make.leading.equalTo(lastBadge.snp.trailing).offset(4)
                } else {
                    make.leading.equalToSuperview()
                }
            }

            lastBadge = badgeView
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
//        if let lastBadge = lastBadge {
//            lastBadge.snp.makeConstraints { make in
//                make.trailing.greaterThanOrEqualToSuperview()
//            }
//        }
    }

    private func getVerticalConstraintsForBadge(
        badge: CinemaBadge
    ) -> (top: CGFloat, bottom: CGFloat) {
        switch badge {
        case .icon:
            return (top: 0, bottom: -5)
        case .text:
            return (top: 1, bottom: -4)
        }
    }

    private func getBadge(
        badge: CinemaBadge
    ) -> UIView {
        switch badge {
        case .icon:
            let label = UILabel()
            label.font = UIFont.font(of: 13, weight: .bold)
            label.text = "🍿"
            return label

        case .text(text: let text):
            let label = UILabel()
            label.font = UIFont.font(of: 10, weight: .semibold)
            label.text = text
            label.textColor = .white
            let tagView = UIView()
            tagView.backgroundColor = self.themeProvider?.current.palette.accent
            tagView.layer.cornerRadius = 7
            tagView.clipsToBounds = true
            tagView.addSubview(label)
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(5)
                make.trailing.equalToSuperview().offset(-5)
                make.top.equalToSuperview().offset(1)
                make.bottom.equalToSuperview().offset(-2)
            }
            return tagView
        }
    }

    func reset() {
        badgesContainerView.subviews.forEach({ $0.removeFromSuperview() })
        title = nil
        subwayColor = nil
        subway = nil
        address = nil
        mall = nil
        distance = nil
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

    @IBAction func didTapFavorite(_ sender: UIButton) {
        addToFavorites()
    }

    @IBAction private func didTapShowMap(_ sender: UIButton) {
        showMap()
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

    private func showMap() {
        guard let id = viewModel?.id, let sdkManager = viewModel?.sdkManager else {
            return
        }

        sdkManager.mapDelegate?.openMap(with: id)
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
            entityName: "cinema",
            id: id,
            source: viewModel?.sourceName
        )

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
                    Favorites.notificationItemIDKey: id,
                    Favorites.notificationItemIsFavoriteNowKey: targetState,
                    Favorites.notificationItemEntityTypeKey: entityType
                ]
            )
        }.cauterize()
    }
}

extension CinemaTileView: ThemeUpdatable {
    func update(with theme: Theme) {
        self.distanceLabel.textColor = theme.palette.accent
        self.favoriteButton.setImage(theme.imageSet.cinemaTileFavoriteNormal, for: .normal)
        self.favoriteButton.setImage(theme.imageSet.cinemaTileFavoriteSelected, for: .selected)
    }
}
