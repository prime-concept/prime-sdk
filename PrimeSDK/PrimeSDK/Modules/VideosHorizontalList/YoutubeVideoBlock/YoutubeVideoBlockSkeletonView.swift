import UIKit

final class YoutubeVideoBlockSkeletonView: UIView {
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 18, weight: .bold)
        return label
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(of: 12, weight: .semibold)
        return label
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle(nil, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()

    override init(
        frame: CGRect = .zero
    ) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.backgroundColor = .white
        self.isSkeletonable = true

        self.thumbnailImageView.isSkeletonable = true
        self.titleLabel.isSkeletonable = true
        self.authorLabel.isSkeletonable = true
        self.shareButton.isSkeletonable = true
    }

    private func addSubviews() {
        [
            self.thumbnailImageView,
            self.titleLabel,
            self.authorLabel,
            self.shareButton
        ].forEach(self.addSubview)
    }

    private func makeConstraints() {
        self.thumbnailImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-60)
        }

        self.authorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.trailing.equalTo(self.shareButton.snp.leading).offset(-45)
            make.height.equalTo(14)
        }

        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalTo(self.authorLabel.snp.top).offset(-5)
            make.trailing.equalTo(self.shareButton.snp.leading).offset(-15)
            make.height.equalTo(20)
        }

        self.shareButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.trailing.equalToSuperview().offset(-15)
            make.width.height.equalTo(34)
        }
    }
}
