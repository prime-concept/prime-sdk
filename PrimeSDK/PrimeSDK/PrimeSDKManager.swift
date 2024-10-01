import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON
import UIKit

public protocol PrimeSDKManagerProtocol: PrimeSDKManagerDataSource {
    var apiDelegate: PrimeSDKApiDelegate? { get set }
    var listDelegate: PrimeSDKListDelegate? { get set }
    var changeCityDelegate: PrimeSDKChangeCityDelegate? { get set }
    var kinohodTicketPurchaseDelegate: PrimeSDKKinohodTicketPurchaseDelegate? { get set }
    var scrollDelegate: PrimeSDKScrollDelegate? { get set }
    var horizontalListDelegate: PrimeSDKHorizontalListDelegate? { get set }
    var filterHorizontalListDelegate: PrimeSDKFilterHorizontalListDelegate? { get set }
    var analyticsDelegate: PrimeSDKAnalyticsDelegate? { get set }
    var mapDelegate: PrimeSDKShowMapDelegate? { get set }
    var detailDelegate: PrimeSDKDetailDelegate? { get set }
    var homeVerticalContainerDelegate: PrimeSDKHomeVerticalContainerDelegate? { get set }
    var quizDelegate: PrimeSDKQuizDelegate? { get set }
    var bookingDelegate: PrimeSDKBookingDelegate? { get set }
}

public protocol PrimeSDKManagerDataSource {
    func reloadList(for name: String, showingIndicator: Bool)
    var reloadBlockForListName: [String: (Bool) -> Void] { get set }

    func reloadCollectionData(for name: String)
    var reloadCollectionDataForListName: [String: () -> Void] { get set }

    func reloadHorizontalListsContainer(for name: String)
    var reloadHorizontalListsContainerForName: [String: () -> Void] { get set }

    var cancelRequestsForName: [String: () -> Void] { get set }
    func cancelRequests(viewName: String)
}

public protocol PrimeSDKAnalyticsDelegate: AnyObject {
    // screen
    func screenOpened(viewName: String, source: String?)
    // detail
    func detailOpened(viewName: String, id: String, source: String)
    // list
    func listOpened(viewName: String, attributes: [String: Any])
    func listOpenedError(viewName: String, error: String?)
    // favorite
    func favoriteToggle(isFavorite: Bool, entityName: String, id: String, source: String?)
    func seanceOpened(cinemaID: String, movieID: String, movieFormat: String, scheduleTime: Date, price: Int)
    func scheduleDateChanged(oldTime: Date, newTime: Date)
    // purchase
    func purchaseSuccessful(
        orderID: String,
        cinemaID: String,
        movieID: String,
        scheduleTime: Date,
        price: Int,
        orderTime: Date,
        movieFormat: String,
        ticketsCount: Int?
    )
    func purchaseUnsuccessful()
    // search
    func searchResultChosen(type: String, id: String, text: String)
    func searchNotFound(text: String)
    // city
    func cityChanged(oldCityName: String, newCityName: String)
    // share
    func shareLinkOpened(viewName: String, id: String)
    func shareSuccess(viewName: String, id: String)
    // ticket
    func ticketToWalletAdd(id: String, cinemaId: String, movieId: String, scheduleTime: Date)
    // map
    func selectInAppMap()
    func selectMap(with type: String)
    // youtube
    func youtubeVideoTap()
    // Main
    func mainBannerButtonClicked(url: String, img: String, text: String, type: String)
    func mainBannerButtonShown(url: String, img: String, text: String, type: String)
    // City Guide
    func cityGuideBannerShown(contentURL: String, imageURL: String)
    func cityGuideBannerClicked(contentURL: String, imageURL: String)
    // Movie
    func movieTrailerOpened(movieID: String, genres: [String])
    func movieSearchCinemaTapped(text: String, movieID: String)
    // JustWatch
    func iviBuyPressed()
    func iviRentPressed()
    // Schedule
    func missingSchedule(cinema: String)

    func sdkNetworkErrorOccurred(request: String, code: Int?, error: String, time: String?)
}

public protocol PrimeSDKApiDelegate: AnyObject {
    func requestLoaded(configRequest: ConfigRequest, response: DataResponse<JSON>)
    func getCachedResponse(configRequest: ConfigRequest) -> JSON?
    func wrapRequest() -> Promise<Void>
    /// Логирование реквеста из СДК
    /// - Parameter sdkRequest: Запрос, отправленный из СДК
    func log(sdkRequest: URLRequest)
    /// Логирование респонса из СДК
    /// - Parameter sdkResponse: Ответ, полученный на запрос из СДК
    func log(sdkResponse: DataResponse<JSON>)
}

public protocol PrimeSDKScrollDelegate: AnyObject {
    func viewDidScroll(yOffset: CGFloat, for name: String)
}

public protocol PrimeSDKListDelegate: AnyObject {
    func getListHeader(
        for name: String,
        collectionView: UICollectionView,
        indexPath: IndexPath,
        controller: UIViewController
    ) -> UICollectionReusableView?
    func getHeaderHeight(for name: String) -> CGFloat?
    func registerHeaderView(for name: String, in collectionView: UICollectionView)
    func getEmtpyView(for name: String) -> UIView?
    func presented(by controller: UIViewController, for listName: String)
    func listUpdatedWithData(count: Int, for name: String)
    func changeHeaderBackground(isReachable: Bool)
    func getCityCoordinate() -> GeoCoordinate?
}

public protocol PrimeSDKChangeCityDelegate: AnyObject {
    func cityChanged(toCity withID: String, title: String)
    func cityCoordinateChanged(toCoordinate: GeoCoordinate)
    func cityChangeFinished()

    //nil if no city is already selected, ID otherwise
    func getSelectedCityID() -> String?

    //Default city ID if no city is selected
    func getDefaultCityID() -> String?
}

public protocol PrimeSDKKinohodTicketPurchaseDelegate: AnyObject {
    // swiftlint:disable:next large_tuple
    func getCredentials() -> Credentials?
    func getApplePayURL() -> URL?
    func orderCompletedSuccessfully(orderID: String, schedule: ScheduleItem)
    func getTicketsCount(orderID: String) -> Promise<Int>
}

public protocol PrimeSDKHorizontalListDelegate: AnyObject {
    func showAllPressed(for name: String)
}

public protocol PrimeSDKShowMapDelegate: AnyObject {
    func openMap(with item: String?)
}

public protocol PrimeSDKDetailDelegate: AnyObject {
    func set(scrollView: UIScrollView)
    func shouldShowCloseButton() -> Bool
    func shouldUseZeroStatusBarHeight() -> Bool
    func isOpenFromMap() -> Bool
}

public protocol PrimeSDKFilterHorizontalListDelegate: AnyObject {
    func didFilterPressed(with name: String)
}

public protocol PrimeSDKHomeVerticalContainerDelegate: AnyObject {
    func updateHeaderImage(isPresent: Bool, viewName: String)
    func getDefaultTopInset() -> CGFloat
}

public protocol PrimeSDKQuizDelegate: AnyObject {
    func listenQuizBannerViewModel(completion:  @escaping ((QuizBannerViewModel?) -> Void))
    func didTapQuiz(id: String)
}

public struct PrimeSDKCanBookInfo {
    public let oneDay: Bool
    public let subscription: Bool
    public let isProfileFilled: Bool

    var canBook: Bool {
        return oneDay || subscription || isProfileFilled
    }

    public init(oneDay: Bool, subscription: Bool, isProfileFilled: Bool) {
        self.oneDay = oneDay
        self.subscription = subscription
        self.isProfileFilled = isProfileFilled
    }
}

public protocol PrimeSDKBookingDelegate: AnyObject {
    var bookingPrivacyPolicyURL: URL { get }
    func changeBookingStatus(bookingID: String, newStatus: String)
    func canBookClub(clubID: String) -> Promise<PrimeSDKCanBookInfo>
    func openProfile(from controller: UIViewController)
}

public class PrimeSDKManager: PrimeSDKManagerProtocol {
    public weak var apiDelegate: PrimeSDKApiDelegate?
    public weak var listDelegate: PrimeSDKListDelegate?
    public weak var changeCityDelegate: PrimeSDKChangeCityDelegate?
    public weak var kinohodTicketPurchaseDelegate: PrimeSDKKinohodTicketPurchaseDelegate?
    public weak var scrollDelegate: PrimeSDKScrollDelegate?
    public weak var horizontalListDelegate: PrimeSDKHorizontalListDelegate?
    public weak var filterHorizontalListDelegate: PrimeSDKFilterHorizontalListDelegate?
    public weak var analyticsDelegate: PrimeSDKAnalyticsDelegate?
    public weak var mapDelegate: PrimeSDKShowMapDelegate?
    public weak var detailDelegate: PrimeSDKDetailDelegate?
    public weak var homeVerticalContainerDelegate: PrimeSDKHomeVerticalContainerDelegate?
    public weak var quizDelegate: PrimeSDKQuizDelegate?
    public weak var bookingDelegate: PrimeSDKBookingDelegate?

    public var reloadBlockForListName: [String: (Bool) -> Void] = [:]
    public var reloadCollectionDataForListName: [String: () -> Void] = [:]
    public var reloadHorizontalListsContainerForName: [String: () -> Void] = [:]

    public init(
        apiDelegate: PrimeSDKApiDelegate? = nil,
        listDelegate: PrimeSDKListDelegate? = nil,
        changeCityDelegate: PrimeSDKChangeCityDelegate? = nil,
        kinohodTicketPurchaseDelegate: PrimeSDKKinohodTicketPurchaseDelegate? = nil,
        scrollDelegate: PrimeSDKScrollDelegate? = nil,
        horizontalListDelegate: PrimeSDKHorizontalListDelegate? = nil,
        analyticsDelegate: PrimeSDKAnalyticsDelegate? = nil,
        mapDelegate: PrimeSDKShowMapDelegate? = nil,
        detailDelegate: PrimeSDKDetailDelegate? = nil,
        filterHorizontalListDelegate: PrimeSDKFilterHorizontalListDelegate? = nil,
        homeVerticalContainerDelegate: PrimeSDKHomeVerticalContainerDelegate? = nil,
        quizDelegate: PrimeSDKQuizDelegate? = nil,
        bookingDelegate: PrimeSDKBookingDelegate? = nil
    ) {
        self.apiDelegate = apiDelegate
        self.listDelegate = listDelegate
        self.changeCityDelegate = changeCityDelegate
        self.kinohodTicketPurchaseDelegate = kinohodTicketPurchaseDelegate
        self.scrollDelegate = scrollDelegate
        self.horizontalListDelegate = horizontalListDelegate
        self.filterHorizontalListDelegate = filterHorizontalListDelegate
        self.analyticsDelegate = analyticsDelegate
        self.mapDelegate = mapDelegate
        self.detailDelegate = detailDelegate
        self.homeVerticalContainerDelegate = homeVerticalContainerDelegate
        self.quizDelegate = quizDelegate
        self.bookingDelegate = bookingDelegate
    }

    public func reloadList(for name: String, showingIndicator: Bool) {
        reloadBlockForListName[name]?(showingIndicator)
    }

    public func reloadCollectionData(for name: String) {
        reloadCollectionDataForListName[name]?()
    }

    public func reloadHorizontalListsContainer(for name: String) {
        reloadHorizontalListsContainerForName[name]?()
    }

    public var cancelRequestsForName: [String: () -> Void] = [:]
    public func cancelRequests(viewName: String) {
        cancelRequestsForName[viewName]?()
    }

    public func getDeeplinkModule(
        branchData: [String: AnyObject],
        configurationLoadingService: ConfigurationLoadingService
    ) -> UIViewController? {
        guard let type = branchData["type"] as? String else {
            return nil
        }

        switch type {
        case "detail":
            guard
                let viewName = branchData["view"] as? String,
                let id = branchData["id"] as? String
            else {
                return nil
            }

            return ConfigurationLoadingViewController(
                viewName: viewName,
                id: id,
                configurationService: configurationLoadingService,
                apiService: APIService(sdkManager: self),
                sdkManager: self
            )
        default:
            return nil
        }
    }
}

struct DeepLinkResult {
    enum TransitionType {
        case push
        case modal
    }

    var controller: UIViewController
    var transitionType: TransitionType
}

public typealias ScheduleItem = KinohodTicketsBookerScheduleViewModel.Schedule

public struct Credentials {
    let apiKey: String
    let userToken: String?
    let deviceID: String
    let sessionID: String?
    let amplitudeDeviceID: String
    let amplitudeSessionID: Int64

    public init(
        apiKey: String,
        userToken: String?,
        deviceID: String,
        sessionID: String?,
        amplitudeDeviceID: String,
        amplitudeSessionID: Int64
    ) {
        self.apiKey = apiKey
        self.userToken = userToken
        self.deviceID = deviceID
        self.sessionID = sessionID
        self.amplitudeDeviceID = amplitudeDeviceID
        self.amplitudeSessionID = amplitudeSessionID
    }
}
