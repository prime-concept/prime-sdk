import Foundation

class KinohodTicketsBookerViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "movie": moduleSource.movieID ?? "",
            "cinema": moduleSource.cinemaID ?? ""
        ]
    }

    var calendar: KinohodTicketsBookerCalendarViewModel?
//    var schedules: KinohodTicketsBookerSchedulesViewModel?

    var schedulesForDate: [String: KinohodTicketsBookerSchedulesViewModel] = [:]
    var currentSchedules: KinohodTicketsBookerSchedulesViewModel? {
        guard
            let calendar = calendar
        else {
            return nil
        }

        if calendar.isDummy {
            return KinohodTicketsBookerSchedulesViewModel.getDummySchedulesViewModel(
                moduleSource: moduleSource
            )
        }

        let currentDay = calendar.days[calendar.selectedIndex]
        return schedulesForDate[currentDay.dateString]
    }


    var noDataText: String

    private var moduleSource: KinohodTicketsBookerModuleSource

    private var sdkManager: PrimeSDKManagerProtocol
    private var configuration: Configuration

    init?(
        name: String,
        moduleSource: KinohodTicketsBookerModuleSource,
        configView: KinohodTicketsBookerConfigView,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.viewName = name
        self.noDataText = configView.attributes.noDataText
        self.moduleSource = moduleSource
        self.configuration = configuration
        self.sdkManager = sdkManager
    }

    func reloadCalendar(
        valueForAttributeID: [String: Any]
    ) {
        self.calendar = KinohodTicketsBookerCalendarViewModel(valueForAttributeID: valueForAttributeID)
        guard let calendar = self.calendar else {
            return
        }
        for day in calendar.days {
            self.schedulesForDate[day.dateString] = KinohodTicketsBookerSchedulesViewModel.getDummySchedulesViewModel(
                moduleSource: moduleSource
            )
        }
    }

//    mutating func reloadSchedules(
//        valueForAttributeID: [String: Any],
//        configView: KinohodTicketsBookerConfigView,
//        otherConfigViews: [String: ConfigView],
//        adBannerDelegate: AdBannerDelegate?,
//        dateString: String
//    ) {
//        guard let newSchedules = KinohodTicketsBookerSchedulesViewModel(
//            valueForAttributeID: valueForAttributeID,
//            configView: configView,
//            moduleSource: moduleSource,
//            otherConfigViews: otherConfigViews,
//            sdkManager: sdkManager,
//            configuration: configuration
//        ) else {
//            return
//        }
//
//        var newSections = filterEmptyBanners(
//            newSections: newSchedules.sections
//        )
//
//        newSections = insertBanners(
//            newSections: newSections,
//            offset: schedules?.cinemasAndAdsCount ?? 0,
//            configView: configView,
//            otherConfigViews: otherConfigViews,
//            adBannerDelegate: adBannerDelegate
//        )
//
//        if schedules == nil || (schedules?.isDummy ?? false) {
//            self.schedules = newSchedules
//            self.schedules?.sections = newSections
//        } else {
//            self.schedules?.sections += newSections
//        }
//        self.cachedValue[dateString] = self.schedules
//    }

    func clear() {
        self.schedulesForDate = [:]
    }

    func loadSchedules(
        valueForAttributeID: [String: Any],
        configView: KinohodTicketsBookerConfigView,
        otherConfigViews: [String: ConfigView],
        adBannerDelegate: AdBannerDelegate?,
        dateString: String
    ) {
        guard let newSchedules = KinohodTicketsBookerSchedulesViewModel(
            valueForAttributeID: valueForAttributeID,
            configView: configView,
            moduleSource: moduleSource,
            otherConfigViews: otherConfigViews,
            sdkManager: sdkManager,
            configuration: configuration
        ) else {
            return
        }

        var newSections = filterEmptyBanners(
            newSections: newSchedules.sections
        )

        newSections = insertBanners(
            newSections: newSections,
            offset: 0,
            configView: configView,
            otherConfigViews: otherConfigViews,
            adBannerDelegate: adBannerDelegate
        )

        newSchedules.sections = newSections

        if self.schedulesForDate[dateString]?.isDummy == true || self.schedulesForDate[dateString] == nil {
            self.schedulesForDate[dateString] = newSchedules
        } else {
            self.schedulesForDate[dateString]?.sections += newSchedules.sections
        }
    }

    private func insertBanners(
        newSections: [KinohodTicketsBookerSchedulesViewModel.ScheduleSection],
        offset: Int,
        configView: KinohodTicketsBookerConfigView,
        otherConfigViews: [String: ConfigView],
        adBannerDelegate: AdBannerDelegate?
    ) -> [KinohodTicketsBookerSchedulesViewModel.ScheduleSection] {
        var resSchedules = newSections
        var currentCinemasAndBannersCount = offset
        var insertedBannersCnt = 0
        for (index, item) in newSections.enumerated() {
            switch item {
            case .cinema, .movie:
                if
                    let configView = configView.ads.first(where: { $0.position == currentCinemasAndBannersCount }),
                    let bannerConfigView = otherConfigViews[configView.name] as? AdBannerConfigView {
                    let adViewModel = AdBannerViewModel(
                        name: bannerConfigView.name,
                        configView: bannerConfigView,
                        sdkManager: sdkManager,
                        delegate: adBannerDelegate,
                        imageAd: nil
                    )

                    resSchedules.insert(
                        KinohodTicketsBookerSchedulesViewModel.ScheduleSection.adBanner(adBanner: adViewModel),
                        at: index + insertedBannersCnt
                    )
                    insertedBannersCnt += 1
                    currentCinemasAndBannersCount += 1
                }
                currentCinemasAndBannersCount += 1
            default:
                break
            }
        }
        return resSchedules
    }

    private func filterEmptyBanners(
        newSections: [KinohodTicketsBookerSchedulesViewModel.ScheduleSection]
    ) -> [KinohodTicketsBookerSchedulesViewModel.ScheduleSection] {
        var resSchedules: [KinohodTicketsBookerSchedulesViewModel.ScheduleSection] = []
        for (index, item) in newSections.enumerated() {
            switch item {
            case .cinema, .movie:
                guard index != newSections.count - 1 else {
                    break
                }
                if
                    case .schedule(rows: let rows) = newSections[index + 1],
                    rows.isEmpty
                {
                    break
                }
                resSchedules += [item]
            case .schedule(rows: let rows):
                if !rows.isEmpty {
                    resSchedules += [item]
                }
            case .adBanner:
                resSchedules += [item]
            }
        }
        return resSchedules
    }
}
