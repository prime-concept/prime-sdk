import Foundation

final class NewListHeaderView: UICollectionReusableView, ProgrammaticallyDesignable, ViewReusable {
    private enum Appearance {
        static let infoNumberOfLines = 0
        static let infoFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let infoColor = UIColor.black
    }

    private lazy var imagesCarouselView = ImageCarouselView()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Appearance.infoNumberOfLines
        label.font = Appearance.infoFont
        label.textColor = Appearance.infoColor
        return label
    }()

    private var images: [GradientImage] = [] {
        didSet {
            self.imagesCarouselView.setImages(with: images.compactMap { URL(string: $0.image) })
        }
    }

    private var info: String? {
        didSet {
            self.infoLabel.text = info
        }
    }

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

    /// Setup view parameters (e.g. set colors, fonts, etc)
    func setupView() {
    }

    /// Set up subviews hierarchy
    func addSubviews() {
        [self.imagesCarouselView, self.infoLabel].forEach(self.addSubview)
    }

    /// Add constraints
    func makeConstraints() {
        self.imagesCarouselView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(250)
        }

        self.infoLabel.snp.makeConstraints { make in
            make.top.equalTo(self.imagesCarouselView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    func setup(wtih header: ListHeaderViewModel) {
        self.images = header.images
        self.info = header.description
    }
}
