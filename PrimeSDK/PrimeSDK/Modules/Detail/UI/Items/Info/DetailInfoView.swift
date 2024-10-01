import SnapKit
import UIKit

final class DetailInfoView: UIView {
    private static let lineSpacing = CGFloat(2)
    private static let numberOfVisibleLines = 5

    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private var collapsedHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleInfoVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientContainerView: GradientContainerView!

    private var skeletonBottomConstraint: Constraint?

    var onExpand: (() -> Void)?

    var text: String? {
        didSet {
            textLabel.setText(text, lineSpacing: DetailInfoView.lineSpacing)
            updateExpandableLabel()
        }
    }

    var showTitle: Bool = true {
        didSet {
            if !self.showTitle {
                self.titleHeightConstraint.constant = 0
                self.titleInfoVerticalConstraint.constant = 0
            }
        }
    }
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }

    private var textColor: UIColor = .black {
        didSet {
            titleLabel?.textColor = textColor
            textLabel?.textColor = textColor
        }
    }

    private var showSkeleton = true

    override var backgroundColor: UIColor? {
        didSet {
            let color: UIColor = backgroundColor ?? .white
            textColor = color.isLight() ? .black : .white
            setupGradient()
        }
    }

    private var previousTextLabelWidth = CGFloat(0)
    private var isExpandForbidden = false
    private var isExpanded: Bool = false
    var isOnlyExpanded = false

    private var numberOfLinesInTextLabel: Int {
        let maxSize = CGSize(
            width: textLabel.frame.size.width,
            height: CGFloat(Float.infinity)
        )
        let charSize = textLabel.font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: textLabel.font as Any],
            context: nil
        )
        let lines = Int(textSize.height / charSize)

        return lines
    }

    private var skeletonView: DetailInfoSkeletonView = .fromNib()

    var isSkeletonShown: Bool = false {
        didSet {
            guard self.showSkeleton else {
                return
            }

            skeletonView.translatesAutoresizingMaskIntoConstraints = false
            if isSkeletonShown {
                self.skeletonBottomConstraint?.activate()
                self.skeletonView.showAnimatedGradientSkeleton()
                setElements(hidden: true)
                self.skeletonView.isHidden = false
            } else {
                self.skeletonBottomConstraint?.deactivate()
                self.skeletonView.isHidden = true
                setElements(hidden: false)
                self.skeletonView.hideSkeleton()
            }
        }
    }

    private func setElements(hidden: Bool) {
        textLabel.isHidden = hidden
        titleLabel.isHidden = hidden
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addSubview(skeletonView)
        skeletonView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            self.skeletonBottomConstraint = make.bottom.equalToSuperview().priority(998).constraint
        }
        isSkeletonShown = false

        bottomTextConstraint.isActive = false

        setupGradient()

        self.textLabel.font = UIFont.font(of: 16, weight: .semibold)
        self.titleLabel.font = UIFont.font(of: 20, weight: .bold)
    }

    @IBAction func onTap(_ sender: Any) {
        expand()
    }

    func setup(viewModel: DetailInfoViewModel) {
        self.showSkeleton = viewModel.showSkeleton
        self.showTitle = viewModel.showTitle

        self.text = viewModel.info
        self.title = viewModel.title

        self.backgroundColor = viewModel.backgroundColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if strongSelf.previousTextLabelWidth != strongSelf.textLabel.bounds.width {
                strongSelf.previousTextLabelWidth = strongSelf.textLabel.bounds.width
                strongSelf.updateExpandableLabel()
            }
        }
    }

    func expand() {
        guard !isExpandForbidden else {
            return
        }

        isExpanded.toggle()
        updateExpandLayout(isExpanded: isExpanded)
    }

    private func updateExpandLayout(isExpanded: Bool) {
        gradientContainerView?.isHidden = isExpanded

        if isExpanded {
            collapsedHeightConstraint.isActive = false
            bottomTextConstraint.isActive = true
        } else {
            collapsedHeightConstraint.isActive = true
            bottomTextConstraint.isActive = false
        }

        onExpand?()
    }

    private func updateExpandableLabel() {
        if !isOnlyExpanded && numberOfLinesInTextLabel > DetailInfoView.numberOfVisibleLines {
            // 15 is top padding for block
            let visibleHeight = 15 +
                textLabel.font.lineHeight * CGFloat(DetailInfoView.numberOfVisibleLines) +
                CGFloat(DetailInfoView.numberOfVisibleLines - 1) * DetailInfoView.lineSpacing
            collapsedHeightConstraint.constant = visibleHeight

            updateExpandLayout(isExpanded: false)
            isExpandForbidden = false
        } else {
            updateExpandLayout(isExpanded: true)
            isExpandForbidden = true
        }
    }

    private func setupGradient() {
        let backgroundColor: UIColor = self.backgroundColor ?? .white

        gradientContainerView?.colors = [
            backgroundColor.withAlphaComponent(0.0).cgColor,
            backgroundColor.withAlphaComponent(0.0).cgColor,
            backgroundColor.withAlphaComponent(0.95).cgColor
        ]
    }
}
