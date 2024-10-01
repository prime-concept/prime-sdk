import Nuke
import UIKit

final class DetailHeaderView: UIView {
    @IBOutlet private weak var imageCarouselView: ImageCarouselView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var smallLabel: PaddingLabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var bottomSubtitleConstraint: NSLayoutConstraint!
    @IBOutlet private weak var subtitleConstraintToSafeArea: NSLayoutConstraint!
    @IBOutlet private weak var subtitleConstraintToSmallLabel: NSLayoutConstraint!
    @IBOutlet private weak var subtitleConstraintToLocationImageView: NSLayoutConstraint!
    @IBOutlet private weak var bottomTitleConstraint: NSLayoutConstraint!
    @IBOutlet private weak var blurView: UIView!
    @IBOutlet private weak var leftTopLabel: UILabel!
    @IBOutlet private weak var ondaLogoImageView: UIImageView!
    @IBOutlet private weak var locationIconImageView: UIImageView!

    private static let ageLabelBackgroundColor = UIColor(
        red: 0.75,
        green: 0.75,
        blue: 0.75,
        alpha: 0.25
    )

    private var isFavoriteButtonHidden: Bool = true {
        didSet {
            favoriteButton.isHidden = isFavoriteButtonHidden
        }
    }

    private var isFavoriteButtonSelected: Bool = false {
        didSet {
            favoriteButton.isSelected = isFavoriteButtonSelected
        }
    }

    var subtitle: String? {
        didSet {
            self.updateSubtitleLabel()
        }
    }

    var city: String? {
        didSet {
            self.updateSubtitleLabel()
        }
    }

    private func updateSubtitleLabel() {
        var text = ""
        if let city = city {
            text += city
        }

        if let subtitle = subtitle {
            if city != nil {
                text += " · "
            }
            text += subtitle
        }

        subtitleLabel.text = text
        bottomSubtitleConstraint.constant = text.isEmpty ? 0 : 15
        bottomTitleConstraint.constant = text.isEmpty ? 0 : 10
    }

    var smallText: String? {
        didSet {
            smallLabel.isHidden = (smallText ?? "").isEmpty
            smallLabel.text = smallText
            subtitleConstraintToSafeArea.priority = smallLabel.isHidden
                ? .defaultHigh
                : .defaultLow
            subtitleConstraintToSmallLabel.priority = smallLabel.isHidden
                ? .defaultLow
                : .defaultHigh
            subtitleConstraintToLocationImageView.priority = smallLabel.isHidden
                ? .defaultHigh
                : .defaultLow
        }
    }

    var leftTopText: String? {
        didSet {
            blurView.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.text = leftTopText
        }
    }

    var shouldShowOndaLogo: Bool = false {
        didSet {
            self.ondaLogoImageView.isHidden = !self.shouldShowOndaLogo
        }
    }

    var onAdd: (() -> Void)?

    var onClose: (() -> Void)?

    var viewModel: DetailHeaderViewModel?

    func set(viewModel: DetailHeaderViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        isFavoriteButtonHidden = !viewModel.isFavoriteAvailable
        isFavoriteButtonSelected = viewModel.isFavorite
        imageCarouselView.isUserInteractionEnabled = viewModel.imagesURL.count > 1
        imageCarouselView.setImages(with: viewModel.imagesURL)
        leftTopText = viewModel.badge
        shouldShowOndaLogo = viewModel.shouldShowOndaLogo
        smallText = viewModel.extraBadge
        city = viewModel.city

        if viewModel.distance?.isEmpty == false {
            subtitle = viewModel.distance
            locationIconImageView.isHidden = false
            smallText = nil
        } else {
            subtitle = viewModel.subtitle
        }

        subtitleConstraintToSafeArea.priority = smallLabel.isHidden && locationIconImageView.isHidden
            ? UILayoutPriority(rawValue: 751)
            : .defaultLow

        if let url = viewModel.logo {
            Nuke.loadImage(with: url, into: self.ondaLogoImageView)
        }
    }

    @IBAction func onCloseButtonClick(_ sender: Any) {
        onClose?()
    }

    @IBAction func onAddButtonTouch(_ button: UIButton) {
        onAdd?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupConstraints()

        smallLabel.layer.cornerRadius = 3
        smallLabel.layer.backgroundColor = DetailHeaderView.ageLabelBackgroundColor.cgColor

        subtitle = nil
        smallText = nil
        shouldShowOndaLogo = false

        favoriteButton.setImage(
            UIImage(named: "plus", in: .primeSdk, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        favoriteButton.setImage(
            UIImage(named: "saved", in: .primeSdk, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
            for: .selected
        )
        favoriteButton.tintColor = .white

        self.setupFonts()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleBookingStatusUpdate(notification:)),
            name: .onBookingStatusUpdate,
            object: nil
        )
    }

    lazy var statusView: DetailHeaderStatusView = {
        let statusView = DetailHeaderStatusView()
        self.imageCarouselView.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.centerY.equalTo(self.closeButton.snp.centerY).offset(4)
            make.leading.equalToSuperview()
        }
        statusView.isHidden = true
        return statusView
    }()

    @objc
    private func handleBookingStatusUpdate(notification: Notification) {
        guard
            let viewModel = viewModel,
            viewModel.shouldUpdateStatus,
            let id = notification.userInfo?["id"] as? String else {
            return
        }

        guard let status = notification.userInfo?["status"] as? String else {
            self.statusView.isHidden = true
            return
        }

        if
            viewModel.id == id
        {
            self.statusView.isHidden = false
            self.statusView.status = status
        }
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func prepareForTransition() {
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.setNeedsLayout()
                self?.closeButton.isHidden = true
            },
            completion: nil
        )
    }

    private func setupConstraints() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        closeButton.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: 6 + statusBarHeight
        ).isActive = true
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 25, weight: .bold)
        self.smallLabel.font = UIFont.font(of: 10, weight: .semibold)
        self.subtitleLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.leftTopLabel.font = UIFont.font(of: 12, weight: .semibold)
    }
}
