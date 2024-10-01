import UIKit

final class ContactLinkButton: UIButton {
    private var type: ContactInfoLink
    private var url: String

    init(type: ContactInfoLink, url: String) {
        self.type = type
        self.url = url
        super.init(frame: .zero)

        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.setImage(self.type.image, for: .normal)

        self.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
    }

    @objc
    private func onButtonTap() {
        guard let url = URL(string: self.url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

enum ContactInfoLink {
    case instagram, facebook, website

    var image: UIImage? {
        switch self {
        case .website:
            return UIImage(named: "detail-site-button", in: .primeSdk, compatibleWith: nil)
        case .facebook:
            return UIImage(named: "detail-fb-button", in: .primeSdk, compatibleWith: nil)
        case .instagram:
            return UIImage(named: "detail-instagram-button", in: .primeSdk, compatibleWith: nil)
        }
    }
}
