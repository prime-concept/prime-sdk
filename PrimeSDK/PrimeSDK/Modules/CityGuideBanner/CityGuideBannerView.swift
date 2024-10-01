import Nuke
import SafariServices
import UIKit

final class CityGuideBannerView: UIView {
    private var viewName: String
    private var sdkManager: PrimeSDKManagerProtocol
    private var viewModel: CityGuideBannerViewModel

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap))
        )

        return imageView
    }()

    init(
        viewName: String,
        sdkManager: PrimeSDKManagerProtocol,
        viewModel: CityGuideBannerViewModel
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
        self.sdkManager.analyticsDelegate?.cityGuideBannerShown(
            contentURL: self.viewModel.contentURL,
            imageURL: self.viewModel.imageURL
        )
    }

    private func addSubviews() {
        self.addSubview(self.imageView)
    }

    private func makeConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(self.viewModel.height)
        }
    }

    @objc
    private func imageViewDidTap() {
        self.sdkManager.analyticsDelegate?.cityGuideBannerClicked(
            contentURL: self.viewModel.contentURL,
            imageURL: self.viewModel.imageURL
        )

        let controller = CityGuideWebViewController(
            contentURL: self.viewModel.contentURLValue,
            headers: (self.viewModel.headers ?? [:])
        )
        controller.modalPresentationStyle = .overFullScreen

        ModalRouter(source: nil, destination: controller).route()
    }
}
