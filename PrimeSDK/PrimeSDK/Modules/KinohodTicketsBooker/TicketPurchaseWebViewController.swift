import Foundation
import PassKit
import SnapKit
import WebKit

class TicketPurchaseWebViewController: UIViewController {
    var webView: WKWebView?

    lazy var spinnerView: SpinnerView = {
        let spinnerView = SpinnerView()
        return spinnerView
    }()

    var schedule: KinohodTicketsBookerScheduleViewModel.Schedule?
    var scheduleID: String? {
        return schedule?.id
    }
    var sdkManager: PrimeSDKManagerProtocol?

    var applePayApiService = KinohodApplePayAPIService()
    var passLibrary = PKPassLibrary()

    let baseURL = "https://kinohod.ru/widget/"

    var currentOrderID: String?
    var currentApplePayItem: KinohodApplePayItem?
    var didPaySuccessfully: Bool = false
    var currentPass: PKPass?

    override func viewDidLoad() {
        super.viewDidLoad()

        initWebView()
        initSpinner()
        spinnerView.isHidden = false
        webView?.navigationDelegate = self
        reloadWebView()
    }
    private func initSpinner() {
        self.view.addSubview(spinnerView)
        spinnerView.snp.makeConstraints { make in
            make.height.width.equalTo(35)
            make.center.equalToSuperview()
        }
    }

    private func reloadWebView() {
        if
            let params = getParamsString(),
            let scheduleID = scheduleID,
            let url = URL(string: "\(baseURL)?\(params)&allow_apple_pay=1#scheme_\(scheduleID)")
        {
            let request = URLRequest(url: url)
            webView?.load(request)
        } else {
            //TODO: Display some empty view
        }
    }

    private func getParamsString() -> String? {
        guard let credentials = sdkManager?.kinohodTicketPurchaseDelegate?.getCredentials() else {
            return nil
        }

        var res = "apikey=\(credentials.apiKey)"

        if let token = credentials.userToken {
            res += "&user_token=\(token)"
        }

        res += "&device_id=\(credentials.deviceID)"

        if sdkManager?.kinohodTicketPurchaseDelegate?.getApplePayURL() != nil {
            res += "&allow_apple_pay=1"
        }

        res += "&amplitude_device_id=\(credentials.amplitudeDeviceID)"
        res += "&amplitude_session_id=\(credentials.amplitudeSessionID)"

        return res
    }

    private func initWebView() {
        let webView = WKWebView()
        self.view.addSubview(webView)

        webView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        self.webView = webView
    }

    private func payWithApplePay(orderID: String) {
        guard
            let applePayURL = sdkManager?.kinohodTicketPurchaseDelegate?.getApplePayURL(),
            let credentials = sdkManager?.kinohodTicketPurchaseDelegate?.getCredentials(),
            let sessionID = credentials.sessionID
        else {
            return
        }

        applePayApiService.getApplePayData(
            url: applePayURL,
            orderID: orderID,
            apiKey: credentials.apiKey,
            sessionID: sessionID
        ).promise.done { [weak self] applePayItem in
            self?.currentApplePayItem = applePayItem
            self?.requestSystemApplePayPayment(applePayItem: applePayItem)
        }.cauterize()
    }

    private func handlePaymentError(error: Error? = nil) {
        sdkManager?.analyticsDelegate?.purchaseUnsuccessful()
        let alert = UIAlertController(
            title: "Не удалось оплатить заказ",
            message: "Повторить попытку?",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "Повторить",
                style: .default,
                handler: { [weak self] _ in
                    if let paymentItem = self?.currentApplePayItem {
                        self?.requestSystemApplePayPayment(applePayItem: paymentItem)
                    } else {
                        self?.reloadWebView()
                    }
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "К выбору мест",
                style: .cancel,
                handler: { [weak self] _ in
                    self?.reloadWebView()
                }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }

    private func requestSystemApplePayPayment(applePayItem: KinohodApplePayItem) {
        if
            let request = PKPaymentRequest(kinohodApplePayItem: applePayItem),
            let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request)
        {
            paymentVC.delegate = self
            self.present(paymentVC, animated: true, completion: nil)
        }
    }

    private func handleSuccessOrder(orderID: String) {
        guard let schedule = self.schedule else {
            assertionFailure("try to handle order with out schedule")
            return
        }

        let onSendAnalytics: (Int?) -> Void = { [weak self] count in
            self?.sdkManager?.analyticsDelegate?.purchaseSuccessful(
                orderID: orderID,
                cinemaID: schedule.cinemaID,
                movieID: schedule.movieID,
                scheduleTime: schedule.startTime,
                price: schedule.minPrice,
                orderTime: Date(),
                movieFormat: schedule.group.name,
                ticketsCount: count
            )
            self?.sdkManager?.kinohodTicketPurchaseDelegate?.orderCompletedSuccessfully(
                orderID: orderID,
                schedule: schedule
            )
        }

        self.sdkManager?.kinohodTicketPurchaseDelegate?
            .getTicketsCount(orderID: orderID)
            .done { count in
                onSendAnalytics(count)
            }
            .catch { error in
                onSendAnalytics(nil)
                print("tickets purhase web view conttoller error: \(error)")
            }
    }
}

extension TicketPurchaseWebViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        if !self.didPaySuccessfully {
            handlePaymentError()
        }
    }

    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationStatus) -> Void
    ) {
        guard
            let orderID = currentOrderID,
            let applePayURL = sdkManager?.kinohodTicketPurchaseDelegate?.getApplePayURL(),
            let credentials = sdkManager?.kinohodTicketPurchaseDelegate?.getCredentials(),
            let sessionID = credentials.sessionID
        else {
            completion(.failure)
            return
        }
        let token = KinohodApplePayToken(paymentToken: payment.token)

        self.applePayApiService.putApplePayToken(
            token: token,
            url: applePayURL,
            orderID: orderID,
            apiKey: credentials.apiKey,
            sessionID: sessionID
        ).promise.done { [weak self] response in
            switch response {
            case .success:
                //TODO: Trigger delegate here
                self?.didPaySuccessfully = true
                completion(.success)
                if
                    let url = URL(string: "https://kinohod.ru/order/\(orderID)/process")
                {
                    let processTicketRequest = URLRequest(url: url)
                    self?.webView?.load(processTicketRequest)
                }
            case .error:
                completion(.failure)
            }
        }.catch { _ in
            completion(.failure)
        }
    }
}

extension TicketPurchaseWebViewController: WKNavigationDelegate {
    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinnerView.isHidden = true

        if
            let urlString = webView.url?.absoluteString,
            let idStart = urlString.range(of: "/payment/applepay/")?.upperBound
        {
            let id = String(urlString[idStart...])
            self.currentOrderID = id
            self.payWithApplePay(orderID: id)
        }
    }

    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (
            URLSession.AuthChallengeDisposition,
            URLCredential?
        ) -> Void
    ) {
        let data = Config.uploadCertificates()

        AsyncAuthChallengeHandler.webViewAddTrusted(certificates: data).handle((challenge, completionHandler))
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        if url.absoluteString.hasSuffix("/pkpass/") {
            decisionHandler(.cancel)
            applePayApiService.loadPKPassData(url: url).promise.done { [weak self]data in
                guard
                    let pass = try? PKPass(data: data),
                    let passModule = PKAddPassesViewController(pass: pass)
                else {
                    return
                }
                self?.currentPass = pass
                passModule.delegate = self
                self?.present(passModule, animated: true, completion: nil)
            }.cauterize()
        } else if url.scheme == "itms-apps" {
            decisionHandler(.cancel)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if
            let orderID = self.currentOrderID,
            url.absoluteString.hasSuffix("/order/success/\(orderID)/")
        {
            decisionHandler(.allow)
            self.handleSuccessOrder(orderID: orderID)
        } else {
            decisionHandler(.allow)
        }
    }
}

extension TicketPurchaseWebViewController: PKAddPassesViewControllerDelegate {
    public func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        controller.dismiss(animated: true)
        guard
            let pass = self.currentPass,
            let orderId = currentOrderID,
            let schedule = schedule
        else {
            return
        }

        if passLibrary.containsPass(pass) {
            sdkManager?.analyticsDelegate?.ticketToWalletAdd(
                id: orderId,
                cinemaId: schedule.cinemaID,
                movieId: schedule.movieID,
                scheduleTime: schedule.startTime
            )
        }
    }
}
