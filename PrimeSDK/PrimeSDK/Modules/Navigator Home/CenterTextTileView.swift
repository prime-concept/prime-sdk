import UIKit

/**
CenterTextTileView sizes:
 - Home (large)
 - Search (small)
*/
enum CenterTextTileSize {
    case small
    case large

    var titleFontSize: CGFloat {
        switch self {
        case .small:
            return 11.0
        case .large:
            return 15.0
        }
    }

    var subtitleFontSize: CGFloat {
        switch self {
        case .small:
            return 11.0
        case .large:
            return 12.0
        }
    }
}

/// View represents tile from Home and Search screens
class CenterTextTileView: ImageTileView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var subtitle: String? {
        didSet {
            subTitleLabel.text = subtitle
        }
    }

    var size: CenterTextTileSize = .large {
        didSet {
            titleLabel.font = titleLabel.font.withSize(
                size.titleFontSize
            )
            subTitleLabel.font = subTitleLabel.font.withSize(
                size.subtitleFontSize
            )
        }
    }

    var hidesSubtitle: Bool = false {
        didSet {
            subTitleLabel.isHidden = hidesSubtitle
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        showShadow = false
    }
}
