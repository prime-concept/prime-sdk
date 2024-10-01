import UIKit

struct HomeHeaderButtonViewConfig {
    let isHidden: Bool
    let title: String
    let textColor: UIColor
    let alpha: Float
    let alphaColor: CGFloat = 0.45
    let cornerRadius: CGFloat
    let background: CGFloat = 0.45
}

func after(
    _ delay: TimeInterval,
           perform block: @escaping () -> Void,
           on queue: DispatchQueue = OperationQueue.current?.underlyingQueue ?? .main
) {
    queue.asyncAfter(deadline: .now() + delay, execute: block)
}

final class HomeHeaderButtonView: UIView {
    private var blurEffectView: UIVisualEffectView?
    private var contentView: UIView?
    private var titleLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.placeSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var config: HomeHeaderButtonViewConfig? {
        didSet {
            self.update()
        }
    }

    // MARK: - Private

    private func placeSubviews() {
        self.layer.masksToBounds = true

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.isUserInteractionEnabled = false

        self.addSubview(blurView)
        self.blurEffectView = blurView
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let contentView = UIView()
        self.contentView = contentView

        blurView.contentView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        titleLabel.font = UIFont.font(of: 17)
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func update() {
        guard let config = self.config, !config.isHidden else {
            self.isHidden = true
            return
        }

        self.layer.cornerRadius = config.cornerRadius

        self.contentView?.backgroundColor = UIColor(white: config.background, alpha: config.alphaColor)
        self.contentView?.alpha = CGFloat(config.alpha)

        self.titleLabel?.text = config.title
        self.titleLabel?.textColor = config.textColor
    }
}
