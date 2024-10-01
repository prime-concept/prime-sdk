import Foundation

final class MovieVideoHeaderSkeletonView: UIView, NibLoadable {
    @IBOutlet private weak var closeButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        closeButton.setImage(
            UIImage(
                named: "detail-skeleton-close",
                in: .primeSdk,
                compatibleWith: nil
            )?.withRenderingMode(.alwaysOriginal),
            for: .normal
        )
    }
}
