import Foundation
import Nuke
import NukeWebPPlugin
import UIKit

class HomeSelectionCard: UIView {
    private var viewModel: HomeSelectionCardViewModel?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.alpha = 0.8
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()

    var isSkeletonShown: Bool = false {
        didSet {
            [
                imageView
            ].forEach {
                isSkeletonShown ? $0?.showAnimatedGradientSkeleton() : $0?.hideSkeleton()
            }
        }
    }

    init() {
        super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with viewModel: HomeSelectionCardViewModel?) {
        self.viewModel = viewModel
        if let url = viewModel?.imageURL {
            Nuke.loadImage(with: url, into: self.imageView)
        }
        self.titleLabel.text = viewModel?.title
        self.subtitleLabel.text = viewModel?.subtitle
    }

    private func setupView() {
        WebPImageDecoder.enable()
    }

    private func addSubviews() {
        [
            self.imageView,
            self.titleLabel,
            self.subtitleLabel
        ].forEach {
            self.addSubview($0)
        }
    }

    private func makeConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(60)
        }

        self.subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
        }
    }
}
