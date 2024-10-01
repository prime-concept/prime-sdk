import UIKit

enum QuestStatus {
    case done
    case available
    case notAvailable

    var image: UIImage {
        guard let image = optionalImage else {
            fatalError("Image doesn't exist")
        }
        return image
    }

    private var optionalImage: UIImage? {
        switch self {
        case .done:
            return UIImage(named: "quest-status-done")
        case .available:
            return UIImage(named: "quest-status-available")
        case .notAvailable:
            return UIImage(named: "quest-status-not-available")
        }
    }

    init?(status: String) {
        switch status {
        case "available":
            self = .available
        case "passed":
            self = .done
        case "unavailable":
            self = .notAvailable
        default:
            return nil
        }
    }
}

class QuestTileView: ImageTileView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var leftTopLabel: PaddingLabel!
    @IBOutlet private weak var blurView: UIView!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private var pointsDescriptionLabel: UILabel!
    @IBOutlet private var placeDescriptionLabel: UILabel!
    @IBOutlet private var statusImageView: UIImageView!

    private var isInit = false

    @IBAction func onShareButtonClick(_ sender: Any) {
        onShareTap?()
    }

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var pointsDescription: String? {
        didSet {
            pointsDescriptionLabel.text = pointsDescription
        }
    }

    var placeDescription: String? {
        didSet {
            placeDescriptionLabel.text = placeDescription
        }
    }

    var leftTopText: String? {
        didSet {
            blurView.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.text = leftTopText
        }
    }

    var status: QuestStatus? {
        didSet {
            statusImageView.isHidden = status == nil
            statusImageView.image = status?.image
        }
    }

    var onShareTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupFonts()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInit {
            isInit = true

            shareButton.setImage(
                UIImage(named: "share")?.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
        }
    }

    private func setupFonts() {
        self.titleLabel.font = UIFont.font(of: 16, weight: .semibold)
        self.leftTopLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.shareButton.titleLabel?.font = UIFont.font(of: 18)
        self.pointsDescriptionLabel.font = UIFont.font(of: 14, weight: .semibold)
        self.placeDescriptionLabel.font = UIFont.font(of: 14, weight: .semibold)
    }
}
