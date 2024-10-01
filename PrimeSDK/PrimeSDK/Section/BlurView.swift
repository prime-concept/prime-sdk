import UIKit

final class BlurView: UIView {
    private static let cornerRadius: CGFloat = 10.0

    private var blurEffectView: UIVisualEffectView?
    private var isInited = false

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = BlurView.cornerRadius
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInited {
            isInited = true
            initGradient()
        }

        guard let blurView = blurEffectView else {
            return
        }

        blurView.frame = bounds
    }

    private func initGradient() {
        self.backgroundColor = UIColor(
            red: 0.45,
            green: 0.45,
            blue: 0.45,
            alpha: 0.45
        )
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.isUserInteractionEnabled = false
        self.insertSubview(blurEffectView, at: 0)

        self.blurEffectView = blurEffectView
    }
}
