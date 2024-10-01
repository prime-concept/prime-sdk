import Nuke
import SafariServices
import UIKit

final class LoyaltyOnboardingBannerView: UIView {
    private var viewName: String
    private var sdkManager: PrimeSDKManagerProtocol
    private var viewModel: LoyaltyOnboardingBannerViewModel

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap))
        )

        return imageView
    }()

    init(
        viewName: String,
        sdkManager: PrimeSDKManagerProtocol,
        viewModel: LoyaltyOnboardingBannerViewModel
    ) {
        self.viewName = viewName
        self.sdkManager = sdkManager
        self.viewModel = viewModel

        super.init(frame: .zero)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setupView() {
        Nuke.loadImage(with: self.viewModel.imageURLValue, into: self.imageView)
    }

    private func addSubviews() {
        self.addSubview(self.imageView)
    }

    private func makeConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(self.viewModel.height)
        }
    }

    @objc
    private func imageViewDidTap() {
        UIApplication.shared.open(
            viewModel.contentURLValue,
            options: [:],
            completionHandler: nil
        )
    }
}
