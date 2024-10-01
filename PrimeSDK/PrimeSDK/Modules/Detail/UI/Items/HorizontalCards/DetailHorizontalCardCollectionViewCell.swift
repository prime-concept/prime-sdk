import UIKit

class DetailHorizontalCardCollectionViewCell: UICollectionViewCell, ViewReusable, ProgrammaticallyDesignable {
    private enum Appearance {
        static let phoneButtonCornerRadius = CGFloat(8)
        static let shadowColor = UIColor.black
        static let shadowRadius = CGFloat(7)
        static let shadowOpacity = Float(0.1)
        static let shadowOffset = CGSize(width: 0, height: 1)
    }

    private(set) lazy var itemView = DetailHorizontalCardView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.itemView.clear()
    }

    override func layoutSubviews() {
        self.updateShadowPosition()
    }

    func setupView() {
    }

    func addSubviews() {
        self.contentView.addSubview(self.itemView)
    }

    func makeConstraints() {
        self.itemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func updateShadowPosition() {
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = Appearance.shadowColor.cgColor
        self.layer.shadowOffset = Appearance.shadowOffset
        self.layer.shadowRadius = Appearance.shadowRadius
        self.layer.shadowOpacity = Appearance.shadowOpacity
        self.layer.cornerRadius = Appearance.shadowRadius
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: Appearance.shadowRadius
        ).cgPath
    }
}
