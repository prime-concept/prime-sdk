import Foundation

class KinohodTicketsBookerSchedulesViewModel: SubviewContainerViewModelProtocol, ListViewModelProtocol {
    typealias ItemType = KinohodTicketsBookerScheduleViewModel

    enum ScheduleSection {
        case adBanner(adBanner: AdBannerViewModel)
        case cinema(cinemaCard: CinemaCardViewModel)
        case schedule(rows: [KinohodTicketsBookerScheduleViewModel.ScheduleRow])
        case movie(movieCard: MovieNowViewModel)
    }
    var sections: [ScheduleSection] = []
    var isDummy: Bool = false

    var scheduleBlocksCount: Int {
        if isDummy {
            return 0
        }
        return sections.filter {
            switch $0 {
            case .cinema, .movie:
                return true
            default:
                return false
            }
        }.count
    }

    var cinemasMoviesAndAdsCount: Int {
        if isDummy {
            return 0
        }
        return sections.filter {
            switch $0 {
            case .cinema, .movie, .adBanner:
                return true
            default:
                return false
            }
        }.count
    }

    convenience init?(
        valueForAttributeID: [String: Any],
        configView: KinohodTicketsBookerConfigView,
        moduleSource: KinohodTicketsBookerModuleSource,
        otherConfigViews: [String: ConfigView],
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        if let cinemaCardConfigView = otherConfigViews[configView.attributes.cinema] as? CinemaCardConfigView {
            self.init(
                valueForAttributeID: valueForAttributeID,
                configView: configView,
                movieID: moduleSource.movieID ?? "",
                cinemaCardConfigView: cinemaCardConfigView,
                sdkManager: sdkManager,
                configuration: configuration
            )
        } else if let movieCardConfigView = otherConfigViews[configView.attributes.movie] as? MovieNowConfigView {
            self.init(
                valueForAttributeID: valueForAttributeID,
                configView: configView,
                cinemaID: moduleSource.cinemaID ?? "",
                movieNowConfigView: movieCardConfigView,
                sdkManager: sdkManager,
                configuration: configuration
            )
        } else {
            return nil
        }
    }

    init(
        valueForAttributeID: [String: Any],
        configView: KinohodTicketsBookerConfigView,
        movieID: String,
        cinemaCardConfigView: CinemaCardConfigView,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        let items = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "schedule",
            initBlock: { valueForAttributeID, _ in
                KinohodTicketsBookerScheduleViewModel(
                    valueForAttributeID: valueForAttributeID,
                    cinemaCardConfigView: cinemaCardConfigView,
                    movieID: movieID,
                    sdkManager: sdkManager,
                    configuration: configuration
                )
            }
        )

        for item in items {
            if let cinema = item.cinema {
                sections.append(.cinema(cinemaCard: cinema))
            }
            sections.append(.schedule(rows: item.rows))
        }
    }

    init(
        valueForAttributeID: [String: Any],
        configView: KinohodTicketsBookerConfigView,
        cinemaID: String,
        movieNowConfigView: MovieNowConfigView,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        let items = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "schedule",
            initBlock: { valueForAttributeID, _ in
                KinohodTicketsBookerScheduleViewModel(
                    valueForAttributeID: valueForAttributeID,
                    movieNowConfigView: movieNowConfigView,
                    cinemaID: cinemaID,
                    sdkManager: sdkManager,
                    configuration: configuration
                )
            }
        )

        for item in items {
            if let movie = item.movie {
                sections.append(.movie(movieCard: movie))
            }
            sections.append(.schedule(rows: item.rows))
        }
    }

    init() {
    }

    static var dummyCinemaViewModel = ScheduleSection.cinema(
        cinemaCard: CinemaCardViewModel(title: "", mall: "", address: "")
    )

    static var dummyMovieViewModel = ScheduleSection.movie(
        movieCard: MovieNowViewModel()
    )

    static func getDummySchedulesViewModel(
        moduleSource: KinohodTicketsBookerModuleSource
    ) -> KinohodTicketsBookerSchedulesViewModel {
        let schedulesViewModel = KinohodTicketsBookerSchedulesViewModel()
        switch moduleSource {
        case .cinema:
            schedulesViewModel.sections = [
                KinohodTicketsBookerSchedulesViewModel.dummyMovieViewModel,
                KinohodTicketsBookerSchedulesViewModel.ScheduleSection.schedule(
                    rows: [
                        KinohodTicketsBookerScheduleViewModel.ScheduleRow.dummyViewModel,
                        KinohodTicketsBookerScheduleViewModel.ScheduleRow.dummyViewModel
                    ]
                ),
                KinohodTicketsBookerSchedulesViewModel.dummyMovieViewModel,
                KinohodTicketsBookerSchedulesViewModel.ScheduleSection.schedule(
                    rows: [
                        KinohodTicketsBookerScheduleViewModel.ScheduleRow.dummyViewModel,
                        KinohodTicketsBookerScheduleViewModel.ScheduleRow.dummyViewModel
                    ]
                )
            ]
        case .movie:
            schedulesViewModel.sections = [
                KinohodTicketsBookerSchedulesViewModel.dummyCinemaViewModel,
                KinohodTicketsBookerSchedulesViewModel.ScheduleSection.schedule(
                    rows: [
                        KinohodTicketsBookerScheduleViewModel.ScheduleRow.dummyViewModel,
                        KinohodTicketsBookerScheduleViewModel.ScheduleRow.dummyViewModel
                    ]
                )
            ]
        }

        schedulesViewModel.isDummy = true
        return schedulesViewModel
    }
}
