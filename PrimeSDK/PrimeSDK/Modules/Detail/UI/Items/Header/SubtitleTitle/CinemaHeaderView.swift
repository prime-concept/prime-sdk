import Foundation
import Nuke
import SnapKit

class CinemaHeaderView: UIView {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var shortTitleLabel: UILabel!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var closeButtonHeight: NSLayoutConstraint!
    @IBOutlet var topTitleLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonTitleLabelVerticalConstraint: NSLayoutConstraint!

    @IBOutlet weak var badgesContainerView: UIView!
    @IBOutlet weak var badgesContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var badgesBottonConstraint: NSLayoutConstraint!

    private var closeButtonSuperViewTopConstraint: Constraint?

    private var skeletonView: CinemaHeaderSkeletonView = .fromNib()
    private var themeProvider: ThemeProvider?

    var onClose: (() -> Void)?

    var shouldShowCloseButton: Bool = false {
        didSet {
            closeButton.isHidden = !shouldShowCloseButton
            skeletonView.closeButton.isHidden = !shouldShowCloseButton
        }
    }

    var shouldUpdateTopConstraint: Bool = false {
        didSet {
            shouldUpdateTopConstraint
                ? closeButtonSuperViewTopConstraint?.activate()
                : closeButtonSuperViewTopConstraint?.deactivate()
            topTitleLabelConstraint.isActive = !shouldUpdateTopConstraint
        }
    }

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

    private func setElements(hidden: Bool) {
//        #if KINOHOD || ILLUZION || CINEMA
//        logoImageView.isHidden = hidden
//        shortTitleLabel.isHidden = hidden
//        #else
//        logoImageView.isHidden = true
//        shortTitleLabel.isHidden = true
//        #endif
        titleLabel.isHidden = hidden
        badgesContainerView.isHidden = hidden
    }

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var shortTitle: String? {
        didSet {
            shortTitleLabel.text = shortTitle
        }
    }

    var logoImagePath: String? {
        didSet {
            if let path = logoImagePath {
                loadImage(path: path)
            }
        }
    }

    private func loadImage(path: String) {
        if let url = URL(string: path) {
            loadImage(url: url)
        }
    }

    private var hasBadges: Bool = false {
        didSet {
            badgesContainerViewHeight.constant = hasBadges ? 30 : 0
        }
    }

    private func loadImage(url: URL) {
        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions.cacheOptions,
            into: logoImageView,
            completion: nil
        )
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.themeProvider = ThemeProvider(themeUpdatable: self)
        self.addSubview(skeletonView)
        skeletonView.alignToSuperview()
        isSkeletonShown = false

        setupConstraints()
        closeButton.setImage(
            UIImage(
                named: "player_close",
                in: .primeSdk,
                compatibleWith: nil
            )?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        closeButton.tintColor = UIColor(hex: 0xA6A6A6)

        closeButton.snp.makeConstraints { make in
            closeButtonSuperViewTopConstraint = make.top.equalToSuperview().offset(15).constraint
        }
        closeButtonSuperViewTopConstraint?.deactivate()

        self.setupFonts()
    }

    private func setupFonts() {
        self.shortTitleLabel.font = UIFont.font(of: 14, weight: .medium)
        self.titleLabel.font = UIFont.font(of: 25, weight: .bold)
    }

    private func setupConstraints() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        closeButton.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: 6 + statusBarHeight
        ).isActive = true
    }

    func set(viewModel: DetailCinemaHeaderViewModel) {
        title = viewModel.title
        shortTitle = viewModel.shortTitle
        logoImagePath = viewModel.imagePath
        hasBadges = viewModel.hasBadge
        if hasBadges {
            addBadges(badges: viewModel.badges)
        }
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
                    make.leading.equalTo(lastBadge.snp.trailing).offset(5)
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
            return (top: 8, bottom: 0)
        case .text:
            return (top: 11, bottom: -1)
        }
    }

    private func getBadge(
        badge: CinemaBadge
    ) -> UIView {
        switch badge {
        case .icon:
            let label = UILabel()
            label.font = UIFont.font(of: 15, weight: .bold)
            label.text = "🍿"
            return label

        case .text(text: let text):
            let label = UILabel()
            label.font = UIFont.font(of: 12, weight: .semibold)
            label.text = text
            label.textColor = .white
            let tagView = UIView()
            tagView.backgroundColor = self.themeProvider?.current.palette.accent
            tagView.layer.cornerRadius = 9
            tagView.clipsToBounds = true
            tagView.addSubview(label)
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(6)
                make.trailing.equalToSuperview().offset(-6)
                make.top.equalToSuperview().offset(2)
                make.bottom.equalToSuperview().offset(-1)
            }
            return tagView
        }
    }

    var estimatedHeight: CGFloat {
        if isSkeletonShown {
            return 118
        }
        var sum1: CGFloat = closeButtonHeight.constant +
            topTitleLabelConstraint.constant + closeButtonTitleLabelVerticalConstraint.constant
        sum1 += badgesContainerViewHeight.constant + badgesBottonConstraint.constant
        var titleHeight: CGFloat = 30
        if let title = title {
            titleHeight = title.height(withConstrainedWidth: UIScreen.main.bounds.width - 30, font: titleLabel.font)
        }

        sum1 += hasTopNotch ? 0 : 20

        sum1 += shouldUpdateTopConstraint ? 15 : 0

        return sum1 + titleHeight + 6
    }

    var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        }
        return false
    }


    @IBAction func closePressed(_ sender: Any) {
        onClose?()
    }
}

extension CinemaHeaderView: ThemeUpdatable {
    func update(with theme: Theme) {
    }
}
