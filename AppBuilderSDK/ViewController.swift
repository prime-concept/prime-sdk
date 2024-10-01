import Alamofire
import PrimeSDK
import SwiftyJSON
import UIKit
import PromiseKit

class ViewController: UIViewController {
    var configurationService: ConfigurationLoadingService?

    convenience init(configurationService: ConfigurationLoadingService) {
        self.init()
        self.configurationService = configurationService
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let configurationService = configurationService else {
            return
        }

        let manager = PrimeSDKManager()
        manager.apiDelegate = self
        manager.listDelegate = self
        manager.changeCityDelegate = self
        manager.kinohodTicketPurchaseDelegate = self

        DataStorage.shared.set(value: "a2ff2df3-9e81-4ba4-9ea6-2d4a71a32247", for: "x-app-token")
        DataStorage.shared.set(value: "ru", for: "language")

        let listController = ConfigurationLoadingViewController(
            viewName: "home-vertical-container",
            configurationService: configurationService,
            sdkManager: manager
        )

        self.addChild(listController)
        self.view.addSubview(listController.view)

        listController.view.alignToSuperview()
        listController.view.translatesAutoresizingMaskIntoConstraints = false

        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
}

extension ViewController: PrimeSDKApiDelegate {
    func requestLoaded(configRequest: ConfigRequest, response: DataResponse<JSON>) {
        switch response.result {
        case let .success(json):
            UserDefaults.standard.set(json.rawString(), forKey: "\(configRequest.url)\(configRequest.parameters)")
        case .failure:
            print("Could not load request in SDK")
        }
    }

    func getCachedResponse(configRequest: ConfigRequest) -> JSON? {
        if let cachedJSONString = UserDefaults.standard.value(forKey: "\(configRequest.url)\(configRequest.parameters)") as? String,
           let data = cachedJSONString.data(using: .utf8) {
            return try? JSON(data: data)
        } else {
            return nil
        }
    }

    func wrapRequest() -> Promise<Void> {
        return Promise { seal in
            seal.fulfill(())
        }
    }
}


extension ViewController: PrimeSDKListDelegate {
    func getListHeader(
        for name: String,
        collectionView: UICollectionView,
        indexPath: IndexPath,
        controller: UIViewController
    ) -> UICollectionReusableView? {
        return nil
    }

    func getEmtpyView(for name: String) -> UIView? {
        return nil
    }

    func presented(by controller: UIViewController, for listName: String) {
    }

    func getCityCoordinate() -> GeoCoordinate? {
        return nil
    }

    func changeHeaderBackground(isReachable: Bool) {
    }

    func listUpdatedWithData(count: Int, for name: String) {
    }

    func registerHeaderView(for name: String, in collectionView: UICollectionView) {
    }

    func getHeaderHeight(for name: String) -> CGFloat? {
        return nil
    }
}

final class HeaderView: UICollectionReusableView, NibLoadable {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension ViewController: PrimeSDKChangeCityDelegate {
    func cityCoordinateChanged(toCoordinate: GeoCoordinate) {
        print("new coordinat: \(toCoordinate)")
    }

    func cityChangeFinished() {
        print("finished")
    }

    func cityChanged(toCity withID: String, title: String) {
        print("City changed to \(withID)")
    }

    func getSelectedCityID() -> String? {
        return "443"
    }

    func getDefaultCityID() -> String? {
        return "1"
    }
}

extension ViewController: PrimeSDKKinohodTicketPurchaseDelegate {
    func orderCompletedSuccessfully(orderID: String, schedule: ScheduleItem) {
        print("hey!")
    }

    // swiftlint:disable:next large_tuple
    func getCredentials() -> (apiKey: String, userToken: String?, deviceID: String, sessionID: String?)? {
        return (
            apiKey: "936ef0f4-6265-37eb-a8d7-93985bd096e2",
            userToken: "U2FsdGVkX1-MKO6WN5RNCptXJJ20R0RRaYIZxl0y3pA",
            deviceID: "083112FF-CDC3-4EFA-B983-43090681DEA3",
            sessionID: nil
        )
    }

    func getApplePayURL() -> URL? {
        return URL(string: "https://api.kinohod.ru/api/rest/mobile/v5/applepay/order/")
    }
}
