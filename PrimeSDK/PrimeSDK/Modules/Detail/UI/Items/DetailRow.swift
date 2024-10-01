import UIKit

enum CellType {
    case place, event
}

enum DetailRow: Equatable, Hashable {
    case info
    case taxi
    case map
    case horizontalItems
    case verticalItems
    case tags
    case share
    case location
    case calendar
    case routePlaces
    case routeMap
    case schedule
    case contactInfo
    case youtubeVideo
    case movieFriendsLikes
    case cinemaAddress
    case extendedInfo
    case onlineCinemaList
    case horizontalCards
    case bookingInfo
    case bookingODPInfo
    case eventCalendar

    // swiftlint:disable:next cyclomatic_complexity
    func makeView(from viewModel: DetailBlockViewModel) -> UIView? {
        switch self {
        case .info:
            guard let viewModel = viewModel as? DetailInfoViewModel else {
                return nil
            }
            let view: DetailInfoView = .fromNib()
            view.setup(viewModel: viewModel)
            return view

        case .taxi:
            guard let viewModel = viewModel as? DetailTaxiViewModel else {
                return nil
            }
            let view: DetailTaxiView = .fromNib()
            view.setup(viewModel: viewModel)
            return view

        case .map:
            guard let viewModel = viewModel as? DetailMapViewModel else {
                return nil
            }
            let view: DetailMapView = .fromNib()
            view.setup(viewModel: viewModel)
            return view

        case .horizontalItems:
            guard
                let viewModel = viewModel as? DetailHorizontalItemsViewModel,
                !viewModel.items.isEmpty
            else {
                return nil
            }
            let view: DetailHorizontalCollectionView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .verticalItems:
            guard
                let viewModel = viewModel as? DetailVerticalItemsViewModel,
                !viewModel.items.isEmpty else
            {
                return nil
            }

            let view = DetailSectionCollectionView<ListCollectionViewCell>()
            view.setup(viewModel: viewModel)
            return view
        case .tags:
            guard
                let viewModel = viewModel as? DetailTagsViewModel,
                !viewModel.items.isEmpty else
            {
                return nil
            }
            let view = DetailTagsView()
            view.setup(viewModel: viewModel)
            return view
        case .share:
            guard
                let viewModel = viewModel as? DetailShareViewModel
            else {
                return nil
            }
            let view: DetailShareView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .location:
            guard let viewModel = viewModel as? DetailLocationViewModel else {
                return nil
            }

            let view: DetailLocationView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .calendar:
            guard let viewModel = viewModel as? DetailCalendarViewModel else {
                return nil
            }
            let view: DetailCalendarView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .routePlaces:
            guard let viewModel = viewModel as? DetailRoutePlacesViewModel else {
                return nil
            }

            let view: DetailRouteView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .routeMap:
            guard let viewModel = viewModel as? DetailRouteMapViewModel else {
                return nil
            }

            let view = DetailRouteMapView()
            view.setup(viewModel: viewModel)
            return view
        case .schedule:
            guard let viewModel = viewModel as? DetailScheduleViewModel else {
                return nil
            }

            let view: DetailScheduleView = .fromNib()
            view.setup(with: viewModel)
            return view
        case .contactInfo:
            guard let viewModel = viewModel as? DetailContactInfoViewModel else {
                return nil
            }
            let view = DetailContactInfoView()
            view.setup(with: viewModel)
            return view
        case .youtubeVideo:
            guard let viewModel = viewModel as? VideosHorizontalListViewModel, !viewModel.subviews.isEmpty else {
                return nil
            }
            let module = viewModel.makeModule()
            switch module {
            case .view(let view):
                return view
            case .viewController(let controller):
                return controller.view
            case .none:
                return nil
            }
        case .movieFriendsLikes:
            guard let viewModel = viewModel as? MovieFriendsLikesViewModel else {
                return nil
            }
            let view: MovieFriendsLikesView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .cinemaAddress:
            guard let viewModel = viewModel as? CinemaAddressViewModel else {
                return nil
            }
            let view: CinemaAddressView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        case .extendedInfo:
            guard let viewModel = viewModel as? DetailExtendedInfoViewModel else {
                return nil
            }
            let view = DetailExtendedInfoView()
            view.setup(with: viewModel)
            return view
        case .onlineCinemaList:
            guard let viewModel = viewModel as? DetailOnlineCinemaListViewModel,
                !viewModel.cinemas.isEmpty
            else {
                return nil
            }
            let view = DetailOnlineCinemaListView()
            view.update(with: viewModel)
            return view
        case .horizontalCards:
            guard let viewModel = viewModel as? DetailHorizontalItemsViewModel else {
                return nil
            }
            let view = DetailHorizontalCardsView()
            view.setup(viewModel: viewModel)
            return view
        case .bookingInfo:
            guard let viewModel = viewModel as? DetailBookingInfoViewModel else {
                return nil
            }
            let view = DetailBookingInfoView()
            return view
        case .bookingODPInfo:
            guard let viewModel = viewModel as? DetailBookingODPInfoViewModel else {
                return nil
            }
            let view = DetailBookingODPInfoView()
//            view.setup(viewModel: viewModel)
            return view
        case .eventCalendar:
            guard let viewModel = viewModel as? DetailCalendarViewModel else {
                return nil
            }
            let view: DetailCalendarView = .fromNib()
            view.setup(viewModel: viewModel)
            return view
        }
    }
}
