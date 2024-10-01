import Foundation

final class CinemaHeaderSkeletonView: UIView, NibLoadable {
    @IBOutlet weak var closeButton: UIButton!

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
