import UIKit
import WebKit

final class CityGuideWebViewController: UIViewController {
    private let contentURL: URL
    private let headers: [String: String]

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: .init())
        webView.navigationDelegate = self
        return webView
    }()

    private lazy var spinnerView: SpinnerView = {
        let view = SpinnerView()
        return view
    }()

    private lazy var closeButton: DetailCloseButton = {
        let button = DetailCloseButton()
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.tintColor = .white

        return button
    }()

    init(contentURL: URL, headers: [String: String]) {
        self.contentURL = contentURL
        self.headers = headers

        super.init(nibName: nil, bundle: nil)
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
        self.setup()
    }

    // MARK: - Private

    private func setupView() {
    }

    private func addSubviews() {
        self.view.addSubview(self.webView)
        self.view.addSubview(self.closeButton)
        self.webView.addSubview(self.spinnerView)
    }

    private func makeConstraints() {
        self.webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.closeButton.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            } else {
                make.top.equalToSuperview().offset(16)
            }
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }

        self.spinnerView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 35, height: 35))
            make.center.equalToSuperview()
        }
    }

    @objc
    private func closeView() {
        self.dismiss(animated: true)
    }

    private func setup() {
        var request = URLRequest(url: self.contentURL)
        self.headers.forEach {
            request.addValue($0.key, forHTTPHeaderField: $0.value)
        }

        self.webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

// swiftlint:disable implicitly_unwrapped_optional
extension CityGuideWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.spinnerView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.spinnerView.isHidden = true
    }
}
