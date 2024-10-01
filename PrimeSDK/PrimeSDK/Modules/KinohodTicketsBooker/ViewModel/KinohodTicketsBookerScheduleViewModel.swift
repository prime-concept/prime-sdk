import Foundation

public struct KinohodTicketsBookerScheduleViewModel: ListViewModelProtocol, SubviewContainerViewModelProtocol {
    typealias ItemType = Schedule

    public struct Schedule {
        public let id: String
        public let startTime: Date
        var startTimeString: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: startTime)
        }

        public let minPrice: Int
        struct Group: Hashable {
            let name: String
            let order: Int

            static var dummyViewModel = Group(name: "name", order: 1)
        }
        var group: Group

        public var movieID: String
        public var cinemaID: String

        init?(
            valueForAttributeID: [String: Any],
            movieID: String,
            cinemaID: String
        ) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            guard
                let id = valueForAttributeID["id"] as? String,
                let dateString = valueForAttributeID["start_time"] as? String,
                let date = dateFormatter.date(from: dateString),
                let minPriceString = valueForAttributeID["min_price"] as? String,
                let minPrice = Int(minPriceString),
                let groupName = valueForAttributeID["group.name"] as? String,
                let orderString = valueForAttributeID["group.order"] as? String,
                let groupOrder = Int(orderString)
            else {
                return nil
            }

            self.id = id
            self.startTime = date
            self.minPrice = minPrice
            self.group = Group(name: groupName, order: groupOrder)
            self.movieID = movieID
            self.cinemaID = cinemaID
        }

        private init() {
            id = ""
            startTime = Date()
            minPrice = 0
            group = Group.dummyViewModel
            movieID = ""
            cinemaID = ""
        }

        static var dummyViewModel = Schedule()
    }

    var cinema: CinemaCardViewModel?
    var movie: MovieNowViewModel?

    private var schedules: [Schedule] = []

    struct ScheduleRow {
        var group: Schedule.Group
        var schedules: [Schedule]

        static var dummyViewModel = ScheduleRow(
            group: KinohodTicketsBookerScheduleViewModel.Schedule.Group.dummyViewModel,
            schedules: [
                KinohodTicketsBookerScheduleViewModel.Schedule.dummyViewModel,
                KinohodTicketsBookerScheduleViewModel.Schedule.dummyViewModel,
                KinohodTicketsBookerScheduleViewModel.Schedule.dummyViewModel,
                KinohodTicketsBookerScheduleViewModel.Schedule.dummyViewModel,
                KinohodTicketsBookerScheduleViewModel.Schedule.dummyViewModel
            ]
        )
    }

    var rows: [ScheduleRow] = []

    init(
        valueForAttributeID: [String: Any],
        movieID: String,
        cinemaID: String
    ) {
        schedules = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "schedules",
            initBlock: { valueForAttributeID, _ in
                Schedule(
                    valueForAttributeID: valueForAttributeID,
                    movieID: movieID,
                    cinemaID: cinemaID
                )
            }
        )
        let groupedSchedules: [Schedule.Group: [Schedule]] = Dictionary(grouping: schedules, by: { $0.group })
        for (group, schedulesForOrder) in groupedSchedules {
            rows += [ScheduleRow(group: group, schedules: schedulesForOrder)]
        }
        rows.sort(by: { $0.group.order < $1.group.order })
    }

    init(
        valueForAttributeID: [String: Any],
        cinemaCardConfigView: CinemaCardConfigView,
        movieID: String,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        let cinemaViewModel = CinemaCardViewModel(
            viewName: cinemaCardConfigView.name,
            sourceName: "tickets-booker",
            valueForAttributeID: KinohodTicketsBookerScheduleViewModel.getValuesForSubview(
                valueForAttributeID: valueForAttributeID,
                subviewName: cinemaCardConfigView.name
            ),
            defaultAttributes: cinemaCardConfigView.attributes,
            sdkManager: sdkManager,
            configuration: configuration
        )

        self.init(
            valueForAttributeID: valueForAttributeID,
            movieID: movieID,
            cinemaID: cinemaViewModel.id
        )

        self.cinema = cinemaViewModel
    }

    init(
        valueForAttributeID: [String: Any],
        movieNowConfigView: MovieNowConfigView,
        cinemaID: String,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        let movieViewModel = MovieNowViewModel(
            viewName: movieNowConfigView.name,
            valueForAttributeID: KinohodTicketsBookerScheduleViewModel.getValuesForSubview(
                valueForAttributeID: valueForAttributeID,
                subviewName: movieNowConfigView.name
            ),
            defaultAttributes: movieNowConfigView.attributes,
            sdkManager: sdkManager,
            configuration: configuration
        )

        self.init(
            valueForAttributeID: valueForAttributeID,
            movieID: movieViewModel.id,
            cinemaID: cinemaID
        )

        self.movie = movieViewModel
    }
}
