import Foundation
import SwiftyJSON

class ConfigViewFactory {
    func make(from json: JSON) throws -> (name: String, view: ConfigView) {
        let type = json["type"].stringValue
        let name = json["name"].stringValue

        guard
            let viewType = ViewType(rawValue: type)
        else {
            throw ViewTypeError(viewType: type)
        }

        switch viewType {
        case .list:
            return (name: name, view: ListConfigView(json: json))
        case .sectionCard:
            return (name: name, view: ListItemConfigView(json: json))
        case .movieNowCard, .eventNowCard:
            return (name: name, view: MovieNowConfigView(json: json))
        case .questCard:
            return (name: name, view: QuestCardConfigView(json: json))
        case .detailContainer:
            return (name: name, view: DetailContainerConfigView(json: json))
        case .detailInfo, .detailEventInfo:
            return (name: name, view: DetailInfoConfigView(json: json))
        case .detailInfoExtended:
            return (name: name, view: DetailExtendedInfoConfigView(json: json))
        case .detailMap:
            return (name: name, view: DetailMapConfigView(json: json))
        case .detailTaxi:
            return (name: name, view: DetailTaxiConfigView(json: json))
        case .detailHorizontalList:
            return (name: name, view: DetailHorizontalListConfigView(json: json))
        case .detailVerticalList:
            return (name: name, view: DetailVerticalListConfigView(json: json))
        case .detailTags:
            return (name: name, view: DetailTagsConfigView(json: json))
        case .detailShare:
            return (name: name, view: DetailShareConfigView(json: json))
        case .detailLocation:
            return (name: name, view: DetailLocationConfigView(json: json))
        case .horizontalListsContainer:
            return (name: name, view: HorizontalListsContainerConfigView(json: json))
        case .detailCalendar:
            return (name: name, view: DetailCalendarConfigView(json: json))
        case .detailRoutePlaces:
            return (name: name, view: DetailRoutePlacesConfigView(json: json))
        case .detailRouteMap:
            return (name: name, view: DetailRouteMapConfigView(json: json))
        case .detailSchedule:
            return (name: name, view: DetailScheduleConfigView(json: json))
        case .detailContactInfo:
            return (name: name, view: DetailContactInfoConfigView(json: json))
        case .navigatorCities:
            return (name: name, view: NavigatorCitiesConfigView(json: json))
        case .navigatorHome:
            return (name: name, view: NavigatorHomeConfigView(json: json))
        case .navigatorHomeImage:
            return (name: name, view: NavigatorHomeImageConfigView(json: json))
        case .homeVerticalContainer:
            return (name: name, view: HomeVerticalContainerConfigView(json: json))
        case .homeHeaderImage:
            return (name: name, view: HomeImageConfigView(json: json))
        case .titledHorizontalList:
            return (name: name, view: TitledHorizontalListConfigView(json: json))
        case .flatMovieCard:
            return (name: name, view: FlatMovieCardConfigView(json: json))
        case .adBannerView:
            return (name: name, view: AdBannerConfigView(json: json))
        case .changeCity:
            return (name: name, view: ChangeCityConfigView(json: json))
        case .detailImageCarouselHeader:
            return (name: name, view: DetailImageCarouselHeaderConfigView(json: json))
        case .detailMovieVideoHeader:
            return (name: name, view: DetailMovieHeaderConfigView(json: json))
        case .kinohodTicketsBooker:
            return (name: name, view: KinohodTicketsBookerConfigView(json: json))
        case .cinemaCard:
            return (name: name, view: CinemaCardConfigView(json: json))
        case .detailCinemaHeader:
            return (name: name, view: DetailCinemaHeaderConfigView(json: json))
        case .movieFriendsLikes:
            return (name: name, view: MovieFriendsLikesConfigView(json: json))
        case .detailCinemaAddress:
            return (name: name, view: DetailCinemaAddressConfigView(json: json))
        case .kinohodSearch:
            return (name: name, view: KinohodSearchConfigView(json: json))
        case .filterHorizontalList:
            return (name: name, view: FilterHorizontalListConfigView(json: json))
        case .filterItem:
            return (name: name, view: FilterItemConfigView(json: json))
        case .moviesPopularityChart:
            return (name: name, view: MoviesPopularityChartConfigView(json: json))
        case .popularityChartRow:
            return (name: name, view: PopularityChartRowConfigView(json: json))
        case .videosHorizontalList:
            return (name: name, view: VideosHorizontalListConfigView(json: json))
        case .youtubeVideoBlock:
            return (name: name, view: YoutubeVideoBlockConfigView(json: json))
        case .cityGuideBanner:
            return (name: name, view: CityGuideBannerConfigView(json: json))
        case .loyaltyOnboardingBanner:
            return (name: name, view: LoyaltyOnboardingBannerConfigView(json: json))
        case .homeSelectionCard, .homeEventCard:
            return (name: name, view: HomeSelectionCardConfigView(json: json))
        case .detailOnlineCinemaList:
            return (name: name, view: DetailOnlineCinemaListConfigView(json: json))
        case .homeColoredContainer:
            return (name: name, view: HomeColoredContainerConfigView(json: json))
        case .detailBottomButton:
            return (name: name, view: DetailBottomButtonConfigView(json: json))
        case .goodToKnow:
            return (name: name, view: ListItemConfigView(json: json))
        case .detailHorizontalCards:
            return (name: name, view: DetailHorizontalListConfigView(json: json))
        case .detailBookingInfo:
            return (name: name, view: DetailBookingInfoConfigView(json: json))
        case .detailBookingODPInfo:
            return (name: name, view: DetailBookingODPInfoConfigView(json: json))
        }
    }
}

final class ListItemViewModelFactory {
    func makeViewModel(
        from configView: ConfigView,
        valueForAttributeID: [String: Any],
        defaultAttributes: ListItemConfigView.Attributes?,
        position: Int?,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)? = nil,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) -> ListItemViewModelProtocol {
        switch configView {
        case is ListItemConfigView:
            return ListItemViewModel(
                name: configView.name,
                valueForAttributeID: valueForAttributeID,
                defaultAttributes: defaultAttributes,
                position: position,
                getDistanceBlock: getDistanceBlock,
                sdkManager: sdkManager,
                configuration: configuration
            )
        case is MovieNowConfigView:
            return MovieNowViewModel(
                name: configView.name,
                valueForAttributeID: valueForAttributeID,
                defaultAttributes: defaultAttributes,
                position: position,
                getDistanceBlock: getDistanceBlock,
                sdkManager: sdkManager,
                configuration: configuration
            )
        case is CinemaCardConfigView:
            return CinemaCardViewModel(
                name: configView.name,
                valueForAttributeID: valueForAttributeID,
                defaultAttributes: defaultAttributes,
                position: position,
                getDistanceBlock: getDistanceBlock,
                sdkManager: sdkManager,
                configuration: configuration
            )
        default:
            fatalError("Another config view type is not supported")
        }
    }
}
