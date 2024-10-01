import Foundation

protocol DetailHeaderViewModelProtocol {
    var title: String? { get }
    var imagePath: String? { get }
    func isEqualTo(otherHeader: DetailHeaderViewModelProtocol) -> Bool
}

struct DetailViewModel: ViewModelProtocol {
    var viewName: String = ""

    var id: String = ""
    var entityType: String = ""
    var shareUrl: String?
    var backgroundColor: UIColor = .white
    var sdkManager: PrimeSDKManagerProtocol?

    var attributes: [String: Any] {
        return [
            "id": id as Any,
            "entity_type": entityType as Any,
            "title": header.title as Any,
            "image_path": header.imagePath as Any,
            "share_url": shareUrl as Any
        ]
    }

    var isFavorite: Bool {
        //TODO: Switch header viewModel types here
        get {
            if let header = header as? DetailHeaderViewModel {
                return header.isFavorite
            }
            return false
        }
        set {
            if var header = header as? DetailHeaderViewModel {
                header.isFavorite = newValue
                self.header = header
            }
        }
    }

    static var empty = DetailViewModel()

    //TODO: Somehow fix this trash
    var header: DetailHeaderViewModelProtocol = DetailHeaderViewModel()
    var bottomButton: DetailBottomButtonViewModel?
    var isFavoriteAvailable: Bool = false

    var ticketPurchaseModule: String?
    var showTicketPurchaseButton: Bool = false

    var rows: [ViewModelProtocol & DetailBlockViewModel] {
        return subviews.compactMap({ rowForName[$0] })
    }

    private var subviews: [String] = []

    var rowForName: [String: ViewModelProtocol & DetailBlockViewModel] = [:]
    init() {}

    //swiftlint:disable:next cyclomatic_complexity
    init?(
        name: String,
        valueForAttributeID: [String: Any],
        configView: DetailContainerConfigView,
        otherConfigViews: [String: ConfigView],
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)?
    ) {
        self.sdkManager = sdkManager
        self.id = configView.attributes.id ?? self.id
        self.entityType = configView.attributes.entityType ?? self.entityType
        self.isFavoriteAvailable = configView.attributes.isFavoriteEnabled
        self.ticketPurchaseModule = configView.attributes.ticketPurchaseModule
        self.showTicketPurchaseButton = configView.attributes.ticketPurchaseModuleShowButton

        self.viewName = name

        self.id = valueForAttributeID["id"] as? String ?? self.id
        self.entityType = valueForAttributeID["entity_type"] as? String ?? self.entityType

        if let backgroundColor = UIColor(
            hex: (valueForAttributeID["background_color"] as? String) ?? configView.attributes.backgroundColorRGB
        ) {
            self.backgroundColor = backgroundColor
        }

        guard let headerConfigView = otherConfigViews[configView.header] else {
            return nil
        }

        switch headerConfigView.type {
        case "detail-image-carousel-header":
            guard let headerConfigView = headerConfigView as? DetailImageCarouselHeaderConfigView else {
                return nil
            }
            self.header = DetailHeaderViewModel(
                valueForAttributeID: DetailViewModel.getValuesForSubview(
                    valueForAttributeID: valueForAttributeID,
                    subviewName: configView.header
                ),
                defaultAttributes: headerConfigView.attributes,
                getDistanceBlock: getDistanceBlock,
                isFavoriteAvailable: self.isFavoriteAvailable
            )

        case "detail-movie-video-header":
            guard let headerConfigView = headerConfigView as? DetailMovieHeaderConfigView else {
                return nil
            }
            self.header = DetailMovieHeaderViewModel(
                valueForAttributeID: DetailViewModel.getValuesForSubview(
                    valueForAttributeID: valueForAttributeID,
                    subviewName: configView.header
                ),
                defaultAttributes: headerConfigView.attributes
            )

        case "detail-cinema-header":
            guard let headerConfigView = headerConfigView as? DetailCinemaHeaderConfigView else {
                return nil
            }
            self.header = DetailCinemaHeaderViewModel(
                valueForAttributeID: DetailViewModel.getValuesForSubview(
                    valueForAttributeID: valueForAttributeID,
                    subviewName: configView.header
                ),
                defaultAttributes: headerConfigView.attributes
            )

        default:
            return nil
        }

        if configView.attributes.isBottomButtonEnabled {
            bottomButton = DetailBottomButtonViewModel(
                valueForAttributeID: valueForAttributeID,
                defaultAttributes: configView.attributes
            )
        }

        if let bottomViewModel = DetailBottomButtonViewModel(
            valueForAttributeID: DetailViewModel.getValuesForSubview(
                valueForAttributeID: valueForAttributeID,
                subviewName: "detail-booking-button"
            ),
            defaultAttributes: configView.attributes
        ) {
            self.bottomButton = bottomViewModel
        }

        self.subviews = configView.subviews

        for subviewName in configView.subviews {
            guard let subview = otherConfigViews[subviewName] else {
                continue
            }
            let subviewValueForAttributeID = DetailViewModel.getValuesForSubview(
                valueForAttributeID: valueForAttributeID,
                subviewName: subviewName
            )

            switch subview.type {
            case "detail-info", "detail-event-info":
                guard let detailInfoSubview = subview as? DetailInfoConfigView else {
                    break
                }
                if let viewModel = try? DetailInfoViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: detailInfoSubview.attributes
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-info-extended":
                if let viewModel = try? DetailExtendedInfoViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-map":
                guard let detailMapSubview = subview as? DetailMapConfigView else {
                    break
                }
                if let viewModel = try? DetailMapViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: detailMapSubview.attributes
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-taxi":
                guard let detailTaxiSubview = subview as? DetailTaxiConfigView else {
                    break
                }
                if let viewModel = try? DetailTaxiViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: detailTaxiSubview.attributes
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-tags":
                guard let detailTagsSubview = subview as? DetailTagsConfigView else {
                    break
                }
                let viewModel = DetailTagsViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: detailTagsSubview.attributes
                )
                rowForName[subview.name] = viewModel
            case "detail-share":
                guard let detailShareSubview = subview as? DetailShareConfigView else {
                    break
                }
                if let viewModel = try? DetailShareViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: detailShareSubview.attributes
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-horizontal-list", "detail-horizontal-cards":
                guard
                    let detailHorizontalList = subview as? DetailHorizontalListConfigView,
                    let itemView = otherConfigViews[detailHorizontalList.item] as? ListItemConfigView
                else {
                        break
                }
                if let viewModel = try? DetailHorizontalItemsViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    listConfigView: detailHorizontalList,
                    itemView: itemView,
                    getDistanceBlock: nil,
                    sdkManager: sdkManager,
                    configuration: configuration
                ) {
                    rowForName[subview.name] = viewModel
                }

            case "detail-vertical-list":
                guard
                    let detailVerticalList = subview as? DetailVerticalListConfigView,
                    let itemView = otherConfigViews[detailVerticalList.item] as? ListItemConfigView
                    else {
                        break
                }
                if let viewModel = try? DetailVerticalItemsViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    listConfigView: detailVerticalList,
                    itemView: itemView,
                    getDistanceBlock: getDistanceBlock,
                    sdkManager: sdkManager,
                    configuration: configuration
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-location":
                guard let detailLocationView = subview as? DetailLocationConfigView else {
                    break
                }
                if let viewModel = try? DetailLocationViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: detailLocationView.attributes
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-calendar":
                guard let detailCalendarSubview = subview as? DetailCalendarConfigView else {
                    break
                }
                if let viewModel = try? DetailCalendarViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: detailCalendarSubview.attributes
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-route-places":
                guard
                    let detailRoutePlacesSubview = subview as? DetailRoutePlacesConfigView,
                    let itemView = otherConfigViews[detailRoutePlacesSubview.item] as? ListItemConfigView
                else {
                    break
                }
                if let viewModel = try? DetailRoutePlacesViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    itemView: itemView,
                    defaultAttributes: detailRoutePlacesSubview.attributes,
                    sdkManager: sdkManager,
                    configuration: configuration
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-route-map":
                guard subview is DetailRouteMapConfigView else {
                    break
                }

                if let viewModel = try? DetailRouteMapViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-schedule":
                guard let detailScheduleSubview = subview as? DetailScheduleConfigView else {
                    break
                }
                if let viewModel = try? DetailScheduleViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: detailScheduleSubview.attributes
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-contact-info":
                if let viewModel = try? DetailContactInfoViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "movie-friends-likes":
                if let viewModel = MovieFriendsLikesViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    sdkManager: sdkManager,
                    configuration: configuration
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-cinema-address":
                if let viewModel = CinemaAddressViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "videos-horizontal-list":
                if let viewModel = VideosHorizontalListViewModel(
                    name: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    sdkManager: sdkManager,
                    configuration: configuration
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-online-cinema-list":
                if let viewModel = DetailOnlineCinemaListViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-booking-info":
                if let viewModel = DetailBookingInfoViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    sdkManager: sdkManager,
                    configuration: configuration
                ) {
                    rowForName[subview.name] = viewModel
                }
            case "detail-booking-odp-info":
                if let viewModel = try? DetailBookingODPInfoViewModel(
                    viewName: subviewName,
                    valueForAttributeID: subviewValueForAttributeID,
                    sdkManager: sdkManager
                ) {
                    rowForName[subview.name] = viewModel
                }
            default:
                print("trying to build unknown row \(subview.type)")
                continue
            }
        }
    }

    mutating func update(block: ViewModelProtocol & DetailBlockViewModel, rowName: String) {
        rowForName[rowName] = block
    }
}
