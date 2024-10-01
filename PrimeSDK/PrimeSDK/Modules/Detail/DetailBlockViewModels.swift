import CoreLocation
import Foundation
// swiftlint:disable file_length
protocol DetailBlockViewModel {
    var detailRow: DetailRow { get }
}

struct DetailInfoViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "text": info as Any
        ]
    }

    let detailRow = DetailRow.info

    var showSkeleton: Bool

    var title: String
    var info: String
    var showTitle = true
    var backgroundColor: UIColor = .white

    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailInfoConfigView.Attributes? = nil
    ) throws {
        guard let info = valueForAttributeID["text"] as? String ?? defaultAttributes?.text else {
            self.info = ""
            self.title = ""
            self.viewName = viewName
            self.showSkeleton = false
            return
        }

        self.showTitle = (valueForAttributeID["show_title"] as? Bool) ?? (defaultAttributes?.showTitle ?? true)

        if
            let backgroundColorString = valueForAttributeID["background_color"] as? String,
            let backgroundColor = UIColor(hex: backgroundColorString)
        {
            self.backgroundColor = backgroundColor
        }

        if let title = ((valueForAttributeID["title"] as? String) ?? defaultAttributes?.title) {
            self.title = title
        } else {
            self.title = NSLocalizedString("AboutMovie", bundle: .primeSdk, comment: "")
        }

        self.showSkeleton = valueForAttributeID["show_skeleton"] as? Bool ?? defaultAttributes?.showSkeleton ?? false

        self.info = info
        self.viewName = viewName
    }
}

struct DetailMapViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "lon": location.longitude,
            "lat": location.latitude,
            "address": address,
            "metro": metro as Any
        ]
    }

    let detailRow = DetailRow.map

    var location: GeoCoordinate
    var address: String
    var metro: String?

    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailMapConfigView.Attributes? = nil
    ) throws {
        guard let lat = valueForAttributeID["lat"] as? Double ?? defaultAttributes?.lat else {
            throw DeserializationAttributeMissingError(attributeName: "lat")
        }
        guard let lon = valueForAttributeID["lon"] as? Double ?? defaultAttributes?.lon else {
            throw DeserializationAttributeMissingError(attributeName: "lon")
        }
        guard let address = valueForAttributeID["address"] as? String ?? defaultAttributes?.address else {
            throw DeserializationAttributeMissingError(attributeName: "address")
        }

        self.location = GeoCoordinate(lat: lat, lng: lon)
        self.address = address
        self.metro = valueForAttributeID["metro"] as? String ?? defaultAttributes?.metro
        self.viewName = viewName
    }
}

struct DetailTaxiViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "yandex_price": yandexTaxiPrice,
            "yandex_url": yandexTaxiURL
        ]
    }

    let detailRow = DetailRow.taxi

    var yandexTaxiPrice: Int
    var yandexTaxiURL: String

    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailTaxiConfigView.Attributes? = nil
    ) throws {
        guard let yandexPrice = valueForAttributeID["yandex_price"] as? Int ?? defaultAttributes?.yandexPrice else {
            throw DeserializationAttributeMissingError(attributeName: "yandex_price")
        }
        guard let yandexURL = valueForAttributeID["yandex_url"] as? String ?? defaultAttributes?.yandexURL else {
            throw DeserializationAttributeMissingError(attributeName: "yandex_url")
        }
        self.yandexTaxiURL = yandexURL
        self.yandexTaxiPrice = yandexPrice
        self.viewName = viewName
    }
}

struct DetailHorizontalItemsViewModel: DetailBlockViewModel, SectionCardListViewModelProtocol,
ViewModelProtocol, Equatable {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    var title: String
    var itemWidth: Float?
    var itemHeight: Float?
    var overlapDelta: Float?

    var itemSize: ItemSizeType {
        return ItemSizeType.custom(
            height: CGFloat(itemHeight ?? 145),
            width: CGFloat(itemWidth ?? 145),
            overlapDelta: CGFloat(overlapDelta ?? -10)
        )
    }

    let detailRow = DetailRow.horizontalItems

    var items: [ListItemViewModel] = []

    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        listConfigView: DetailHorizontalListConfigView,
        itemView: ListItemConfigView,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)?,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) throws {
        self.title = valueForAttributeID["title"] as? String ?? listConfigView.attributes.title
        self.itemHeight = valueForAttributeID["item_height"] as? Float ?? listConfigView.attributes.itemHeight
        self.itemWidth = valueForAttributeID["item_width"] as? Float ?? listConfigView.attributes.itemWidth
        self.overlapDelta = valueForAttributeID["overlap_delta"] as? Float ?? listConfigView.attributes.overlapDelta

        self.viewName = viewName

        self.items = getItems(
            valueForAttributeID: valueForAttributeID,
            itemView: itemView,
            getDistanceBlock: getDistanceBlock,
            sdkManager: sdkManager,
            configuration: configuration
        )
    }
}

struct DetailVerticalItemsViewModel: DetailBlockViewModel, SectionCardListViewModelProtocol,
ViewModelProtocol, Equatable {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    var title: String
    var itemHeight: Float?

    var itemSizeType: ItemSizeType {
        return .custom(
            height: CGFloat(itemHeight ?? 120),
            width: 0,
            overlapDelta: 0
        )
    }

    let detailRow = DetailRow.verticalItems

    var items: [ListItemViewModel] = []

    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        listConfigView: DetailVerticalListConfigView,
        itemView: ListItemConfigView,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)?,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) throws {
        self.title = valueForAttributeID["title"] as? String ?? listConfigView.attributes.title
        self.itemHeight = valueForAttributeID["item_height"] as? Float ?? listConfigView.attributes.itemHeight
        self.viewName = viewName

        self.items = getItems(
            valueForAttributeID: valueForAttributeID,
            itemView: itemView,
            getDistanceBlock: getDistanceBlock,
            sdkManager: sdkManager,
            configuration: configuration
        )
    }
}

struct DetailTagsViewModel: DetailBlockViewModel, ListViewModelProtocol,
ViewModelProtocol, Equatable {
    typealias ItemType = String

    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    let detailRow = DetailRow.tags

    var items: [String] = []
    var textColor: UIColor?

    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailTagsConfigView.Attributes? = nil
    ) {
        self.viewName = viewName
        self.items = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "items",
            initBlock: { itemValueForAttributeID, _ in
                itemValueForAttributeID["title"] as? String
            }
        )
        if let color = defaultAttributes?.textColor {
            self.textColor = UIColor(color)
        }
    }
}

struct DetailShareViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    let detailRow = DetailRow.share

    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "title": title as Any,
            "button_title": buttonTitle as Any
        ]
    }

    var title: String
    var buttonTitle: String

    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailShareConfigView.Attributes? = nil
    ) throws {
        guard let title = valueForAttributeID["title"] as? String ?? defaultAttributes?.title else {
            throw DeserializationAttributeMissingError(attributeName: "title")
        }
        guard let buttonTitle = valueForAttributeID["button_title"] as? String ?? defaultAttributes?.buttonTitle else {
            throw DeserializationAttributeMissingError(attributeName: "button_title")
        }
        self.viewName = viewName
        self.title = title
        self.buttonTitle = buttonTitle
    }
}


struct DetailLocationViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    let detailRow: DetailRow = .location

    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "price": taxiPrice as Any,
            "url": taxiURL as Any,
            "address": address,
            "lon": location.longitude,
            "lat": location.latitude
        ]
    }

    var title: String
    var taxiTitle: String
    var priceEndingTitle: String
    var fromTitle: String
    var taxiPrice: Int?
    var taxiURL: String?
    var address: String
    var location: GeoCoordinate

    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailLocationConfigView.Attributes? = nil
    ) throws {
        guard let title = valueForAttributeID["title"] as? String ?? defaultAttributes?.title else {
            throw DeserializationAttributeMissingError(attributeName: "title")
        }
        guard let taxiTitle = valueForAttributeID["taxi_title"] as? String ?? defaultAttributes?.taxiTitle else {
            throw DeserializationAttributeMissingError(attributeName: "taxi_title")
        }
        guard let priceEndingTitle = valueForAttributeID["price_ending_title"] as? String
            ?? defaultAttributes?.priceEndingTitle
        else {
            throw DeserializationAttributeMissingError(attributeName: "price_ending_title")
        }
        guard let fromTitle = valueForAttributeID["from"] as? String ?? defaultAttributes?.fromTitle else {
            throw DeserializationAttributeMissingError(attributeName: "title")
        }
        guard let lat = valueForAttributeID["lat"] as? Double ?? defaultAttributes?.lat else {
            throw DeserializationAttributeMissingError(attributeName: "lat")
        }
        guard let lon = valueForAttributeID["lon"] as? Double ?? defaultAttributes?.lon else {
            throw DeserializationAttributeMissingError(attributeName: "lon")
        }
        guard let address = valueForAttributeID["address"] as? String ?? defaultAttributes?.address else {
            throw DeserializationAttributeMissingError(attributeName: "address")
        }

        self.title = title
        self.taxiTitle = taxiTitle
        self.priceEndingTitle = priceEndingTitle
        self.fromTitle = fromTitle
        self.location = GeoCoordinate(lat: lat, lng: lon)
        self.address = address
        self.viewName = viewName

        if let price = valueForAttributeID["price"] as? Int ?? defaultAttributes?.taxiPrice,
            let url = valueForAttributeID["url"] as? String {
            taxiURL = url
            taxiPrice = price
        }
    }
}

struct DetailCalendarViewModel: DetailBlockViewModel, ListViewModelProtocol, ViewModelProtocol, Equatable {
    typealias ItemType = ItemSchedule

    let detailRow = DetailRow.calendar

    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "notification_text": notificationText,
            "add_to_calendar_text": addToCalendarText,
            "no_event_text": noEventText
        ]
    }

    var notificationText: String
    var addToCalendarText: String
    var noEventText: String

    struct ItemSchedule {
        var mainDate: Date
        var shortSchedules: [DetailCalendarEventsViewModel.ShortItemSchedule]
    }

    struct EventItem: Equatable {
        var startDate: Date
        var endDate: Date
        var title: String

        var mainDateString: String {
            return FormatterHelper.formatDateOnlyWeekDayAndDayAndMonth(startDate)
        }

        var eventDescription: String {
            let time = FormatterHelper.formatTimeFromInterval(from: startDate, to: endDate)
            return "\(time) \(title)"
        }

        var timeString: String {
            return FormatterHelper.formatTimeFromInterval(
                from: startDate,
                to: endDate
            )
        }
    }

    struct DayItem: Equatable {
        var dayOfWeek: String
        var dayNumber: String
        var month: String
        var hasEvents: Bool
        var date: Date
    }

    var events: [[EventItem]] = []
    var firstDateIndex: Int = 0
    var firstDate = Date()
    var days: [DayItem] = []

    var nearestDate: Date? {
        let date = Date()
        var minimumDate: Date?
        events.forEach { element  in
            element.forEach {  event in
                if event.startDate > date {
                    if let minDate = minimumDate {
                        if event.startDate < minDate {
                            minimumDate = event.startDate
                        }
                    } else {
                        minimumDate = event.startDate
                    }
                }
            }
        }
        return minimumDate
    }

    var nearestDateString: String {
        guard let nearestDate = nearestDate else {
            return ""
        }

        return FormatterHelper.formatDateOnlyDayAndMonth(nearestDate)
    }

    // swiftlint:disable:next cyclomatic_complexity
    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailCalendarConfigView.Attributes? = nil
    ) throws {
        guard
            let notificationText = valueForAttributeID[
                "notification_text"
            ] as? String ?? defaultAttributes?.notificationText
        else {
            throw DeserializationAttributeMissingError(attributeName: "notification_text")
        }
        guard
            let addToCalendarText = valueForAttributeID[
                "add_to_calendar_text"
            ] as? String ?? defaultAttributes?.addToCalendarText
        else {
            throw DeserializationAttributeMissingError(attributeName: "add_to_calendar_text")
        }

        guard
            let noEventText = valueForAttributeID[
                "no_event_text"
            ] as? String ?? defaultAttributes?.noEventText
        else {
            throw DeserializationAttributeMissingError(attributeName: "no_event_text")
        }

        self.viewName = viewName
        self.notificationText = notificationText
        self.addToCalendarText = addToCalendarText
        self.noEventText = noEventText

        let schedule = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "schedule",
            initBlock: { itemValueForAttributeID, _ in
                guard let date = Date(
                    string: itemValueForAttributeID["main_date"] as? String ?? ""
                )
                else {
                    return nil
                }
                let shortSchedules = DetailCalendarEventsViewModel(
                    valueForAttributeID: itemValueForAttributeID
                )

                return ItemSchedule(mainDate: date, shortSchedules: shortSchedules.items)
            }
        )

        let sortedSchedule = schedule.sorted(by: { $0.mainDate < $1.mainDate })

        guard var firstDate = sortedSchedule.first?.mainDate,
            let lastDate = sortedSchedule.last?.mainDate else {
                throw PrimeSDKError()
        }

        var eventsMap: [Date: [DetailCalendarViewModel.EventItem]] = [:]
        for record in schedule {
            for event in record.shortSchedules {
                let normalizedMainDate = Calendar.current.startOfDay(for: record.mainDate)
                eventsMap[normalizedMainDate] = eventsMap[normalizedMainDate] ?? []
                eventsMap[normalizedMainDate]?.append(
                    DetailCalendarViewModel.EventItem(
                        startDate: event.start,
                        endDate: event.end,
                        title: event.description
                    )
                )
            }
        }

        let calendar = Calendar.current
        let secondsInDay = 24 * 60 * 60
        firstDate = calendar
            .startOfDay(for: firstDate)
        let startDate = calendar
            .startOfDay(for: Date())
            .addingTimeInterval(-TimeInterval(secondsInDay))
        let dateEnding = calendar
            .startOfDay(for: lastDate)

        let midnightComponents = DateComponents(hour: 0, minute: 0, second: 0)

        var days: [DetailCalendarViewModel.DayItem] = []
        var events: [[DetailCalendarViewModel.EventItem]] = []
        var firstDateIndex = 0
        calendar.enumerateDates(
            startingAfter: startDate,
            matching: midnightComponents,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date <= dateEnding {
                    if date == firstDate {
                        firstDateIndex = days.count
                    }

                    let day = calendar.component(.day, from: date)
                    let weekdayNumber = calendar.component(.weekday, from: date)
                    let month = calendar.component(.month, from: date)

                    let dayEvents = eventsMap[date]

                    days.append(
                        DetailCalendarViewModel.DayItem(
                            dayOfWeek: calendar.shortWeekdaySymbols[weekdayNumber - 1],
                            dayNumber: "\(day)",
                            month: calendar.shortMonthSymbols[month - 1],
                            hasEvents: dayEvents != nil,
                            date: date
                        )
                    )

                    events.append(dayEvents ?? [])
                } else {
                    stop = true
                }
            }
        }

        if days.isEmpty {
            throw PrimeSDKError()
        }

        self.events = events
        self.firstDateIndex = firstDateIndex
        self.firstDate = firstDate
        self.days = days
    }
}

struct DetailCalendarEventsViewModel: ListViewModelProtocol, Equatable {
    typealias ItemType = ShortItemSchedule

    struct ShortItemSchedule: Equatable {
        var start: Date
        var end: Date
        var description: String
    }

    var items: [ShortItemSchedule] = []

    init(valueForAttributeID: [String: Any]) {
        items = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "events",
            initBlock: { itemValueForAttributeID, _ in
                guard let start = Date(string: itemValueForAttributeID["start"] as? String ?? ""),
                    let end = Date(string: itemValueForAttributeID["end"] as? String ?? "")
                else {
                    return nil
                }
                let description = itemValueForAttributeID["description"] as? String
                return ShortItemSchedule(start: start, end: end, description: description ?? "")
            }
        )
    }
}

struct DetailRoutePlacesViewModel: DetailBlockViewModel, ViewModelProtocol,
SectionCardListViewModelProtocol, Equatable {
    enum RoutePoint: Equatable {
        case place(item: ListItemViewModel)
        case direction(description: String)
    }

    var detailRow = DetailRow.routePlaces

    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    var startRoute: String?
    var endRoute: String?
    var items: [RoutePoint] = []
    var places: [ListItemViewModel] = []

    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        itemView: ListItemConfigView,
        defaultAttributes: DetailRoutePlacesConfigView.Attributes? = nil,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) throws {
        guard
            let startRoute = valueForAttributeID[
                "start_route_text"
            ] as? String ?? defaultAttributes?.startRoute
        else {
            throw DeserializationAttributeMissingError(attributeName: "start_route_text")
        }
        guard
            let endRoute = valueForAttributeID[
                "end_route_text"
            ] as? String ?? defaultAttributes?.endRoute
        else {
            throw DeserializationAttributeMissingError(attributeName: "end_route_text")
        }
        self.viewName = viewName

        self.startRoute = startRoute
        self.endRoute = endRoute

        places = getItems(
            valueForAttributeID: valueForAttributeID,
            itemView: itemView,
            getDistanceBlock: nil,
            sdkManager: sdkManager,
            configuration: configuration
        )

        for place in places {
            guard !place.routeDescription.isEmpty else {
                return
            }

            items.append(.place(item: place))
            items.append(.direction(description: place.routeDescription))
        }
    }
}

struct DetailRouteMapViewModel: DetailBlockViewModel, ViewModelProtocol, ListViewModelProtocol, Equatable {
    typealias ItemType = GeoCoordinate

    var detailRow = DetailRow.routeMap

    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "polyline": polyline,
            "origin": routeLocations.first?.latLongString() ?? "",
            "destination": routeLocations.last?.latLongString() ?? "",
            "waypoints": routeLocations.dropFirst().dropLast().map { $0.latLongString() }.joined(separator: "|"),
            "locations": routeLocations
        ]
    }

    var polyline: String = ""
    var routeLocations: [GeoCoordinate] = []

    init(
        viewName: String,
        valueForAttributeID: [String: Any]
    ) throws {
        self.viewName = viewName
        routeLocations = valueForAttributeID["locations"] as? [GeoCoordinate]
            ?? initItems(
                valueForAttributeID: valueForAttributeID,
                listName: "route-locations",
                initBlock: { itemValueForAttributeID, _ in
                    guard let lng = itemValueForAttributeID["lng"] as? Double,
                        let lat = itemValueForAttributeID["lat"] as? Double
                    else {
                        return nil
                    }
                    return GeoCoordinate(lat: lat, lng: lng)
                }
        )
        guard let polyline = valueForAttributeID["polyline"] as? String else {
            return
        }
        self.polyline = polyline
    }
}

struct DetailScheduleViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    let detailRow = DetailRow.schedule

    struct DaySchedule: Equatable {
        var startDate: String?
        var endDate: String?
        var closed: Bool
        var weekday: Int?
        var title: String
        var selected: Bool

        var openedTitle: String
        var closedTitle: String

        var timeString: String {
            if let startDate = startDate, let endDate = endDate {
                return "\(startDate) - \(endDate)"
            } else if !closed {
                return openedTitle
            } else {
                return closedTitle
            }
        }
    }

    var items: [DaySchedule] = []

    var closeUntilTitle: String
    var openUntilTitle: String

    var closedTitle: String
    var openedTitle: String

    var showButtonTitle: String
    var hideButtonTitle: String
    var buttonTitleColor = UIColor.black

    var title: String

    var openStatus: String {
        let currentDate = weekday(for: Date())
        let calendar = Calendar.current
        let currentHours = calendar.component(.hour, from: Date())
        if let date = items.first(where: { $0.weekday == currentDate }) {
            if let openTime = date.startDate,
                let closedTime = date.endDate,
                let openHours = Int(openTime.prefix(2)),
                var closedHours = Int(closedTime.prefix(2)) {
                if closedHours < openHours {
                    closedHours += 24
                }

                if  currentHours >= openHours, currentHours < closedHours {
                    return "\(openUntilTitle) \(closedTime)"
                }

                if currentHours <= openHours {
                    return "\(closeUntilTitle) \(openTime)"
                }

                if currentHours >= closedHours {
                    return closedTitle
                }
            } else if date.closed {
                return closedTitle
            } else {
                return openedTitle
            }
        }

        return ""
    }

    // swiftlint:disable cyclomatic_complexity
    init(
        viewName: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailScheduleConfigView.Attributes? = nil
    ) throws {
        guard let days = valueForAttributeID["days"] as? [String: Any] else {
             throw DeserializationAttributeMissingError(attributeName: "days")
        }
        guard let closeUntilTitle = defaultAttributes?.closeUntilTitle else {
            throw DeserializationAttributeMissingError(attributeName: "close_until_title")
        }
        guard let openUntilTitle = defaultAttributes?.openUntilTitle else {
            throw DeserializationAttributeMissingError(attributeName: "open_until_title")
        }
        guard let openedTitle = defaultAttributes?.openedTitle else {
            throw DeserializationAttributeMissingError(attributeName: "opened_title")
        }
        guard let closedTitle = defaultAttributes?.closedTitle else {
            throw DeserializationAttributeMissingError(attributeName: "closed_title")
        }
        guard let showButtonTitle = defaultAttributes?.showButtonTitle else {
            throw DeserializationAttributeMissingError(attributeName: "button_title")
        }
        guard let hideButtonTitle = defaultAttributes?.hideButtonTitle else {
            throw DeserializationAttributeMissingError(attributeName: "hide_button_title")
        }
        guard let title = defaultAttributes?.title else {
            throw DeserializationAttributeMissingError(attributeName: "title")
        }

        self.viewName = viewName

        self.closedTitle = closedTitle
        self.openedTitle = openedTitle

        self.closeUntilTitle = closeUntilTitle
        self.openUntilTitle = openUntilTitle

        self.showButtonTitle = showButtonTitle
        self.hideButtonTitle = hideButtonTitle

        self.title = title

        if let buttonTitleColorHex = defaultAttributes?.buttonTitleColor {
            self.buttonTitleColor = UIColor(buttonTitleColorHex)
        }

        if let mondayDict = days["Mon"] as? [String: Any] {
            if let monday = convertToDaySchedule(
                dict: mondayDict,
                weekday: 2,
                title: defaultAttributes?.mondayTitle ?? "Monday"
            ) {
                items.append(monday)
            } else {
                throw DeserializationAttributeMissingError(attributeName: "Mon")
            }
        } else {
            throw DeserializationAttributeMissingError(attributeName: "Mon")
        }
        if let tuesdayDict = days["Tue"] as? [String: Any] {
            if let tuesday = convertToDaySchedule(
                dict: tuesdayDict,
                weekday: 3,
                title: defaultAttributes?.tuesdayTitle ?? "Tuesday"
            ) {
                items.append(tuesday)
            } else {
                throw DeserializationAttributeMissingError(attributeName: "Tue")
            }
        } else {
            throw DeserializationAttributeMissingError(attributeName: "Tue")
        }
        if let wednesdayDict = days["Wed"] as? [String: Any] {
            if let wednesday = convertToDaySchedule(
                dict: wednesdayDict,
                weekday: 4,
                title: defaultAttributes?.wednesdayTitle ?? "Wednesday"
            ) {
                items.append(wednesday)
            } else {
                throw DeserializationAttributeMissingError(attributeName: "Wed")
            }
        } else {
            throw DeserializationAttributeMissingError(attributeName: "Wed")
        }
        if let thursdayDict = days["Thu"] as? [String: Any] {
            if let thursday = convertToDaySchedule(
                dict: thursdayDict,
                weekday: 5,
                title: defaultAttributes?.thursdayTitle ?? "Thursday"
            ) {
                items.append(thursday)
            } else {
                throw DeserializationAttributeMissingError(attributeName: "Thu")
            }
        } else {
            throw DeserializationAttributeMissingError(attributeName: "Thu")
        }
        if let fridayDict = days["Fri"] as? [String: Any] {
            if let friday = convertToDaySchedule(
                dict: fridayDict,
                weekday: 6,
                title: defaultAttributes?.fridayTitle ?? "Friday"
            ) {
                items.append(friday)
            } else {
                throw DeserializationAttributeMissingError(attributeName: "Fri")
            }
        } else {
            throw DeserializationAttributeMissingError(attributeName: "Fri")
        }
        if let saturdayDict = days["Sat"] as? [String: Any] {
            if let saturday = convertToDaySchedule(
                dict: saturdayDict,
                weekday: 7,
                title: defaultAttributes?.saturdayTitle ?? "Saturday"
            ) {
                items.append(saturday)
            } else {
                throw DeserializationAttributeMissingError(attributeName: "Sat")
            }
        } else {
            throw DeserializationAttributeMissingError(attributeName: "Sat")
        }
        if let sundayDict = days["Sun"] as? [String: Any] {
            if let sunday = convertToDaySchedule(
                dict: sundayDict,
                weekday: 1,
                title: defaultAttributes?.sundayTitle ?? "Sunday"
            ) {
                items.append(sunday)
            } else {
                throw DeserializationAttributeMissingError(attributeName: "Sun")
            }
        } else {
            throw DeserializationAttributeMissingError(attributeName: "Sun")
        }
    }
    // swiftlint:enable cyclomatic_complexity

    private func convertToDaySchedule(dict: [String: Any], weekday: Int, title: String) -> DaySchedule? {
        guard let closed = dict["closed"] as? Bool else {
            return nil
        }

        return DaySchedule(
            startDate: dict["startTime"] as? String,
            endDate: dict["endTime"] as? String,
            closed: closed,
            weekday: weekday,
            title: title,
            selected: weekday == self.weekday(for: Date()),
            openedTitle: self.openedTitle,
            closedTitle: self.closedTitle
        )
    }

    private func weekday(for date: Date) -> Int {
        let calendar = Calendar.current.component(.weekday, from: date)
        return calendar
    }

    static func == (lhs: DetailScheduleViewModel, rhs: DetailScheduleViewModel) -> Bool {
        return lhs.items == rhs.items
    }
}

struct DetailContactInfoViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    let detailRow = DetailRow.contactInfo

    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    var phone: String?
    var site: String?

    init(viewName: String, valueForAttributeID: [String: Any]) throws {
        self.site = valueForAttributeID["site"] as? String
        self.phone = valueForAttributeID["phone"] as? String

        if self.isEmpty {
            throw DeserializationAttributeMissingError(attributeName: "site or phone")
        }

        self.viewName = viewName
    }

    var isLinksAvailable: Bool {
        return !(site ?? "").isEmpty
    }

    private var isEmpty: Bool {
        return (self.phone ?? "").isEmpty && (self.site ?? "").isEmpty
    }
}

struct DetailExtendedInfoViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    struct BlockInfo {
        let title: String
        let subtitle: String
    }

    enum Blocks: String {
        case directors
        case actors
        case producers
        case premiereDateRussia

        static var cases: [Blocks] {
            [.directors, .actors, .producers, .premiereDateRussia]
        }
    }
    let detailRow = DetailRow.extendedInfo

    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    private var directors: [String] = []
    private var actors: [String] = []
    private var producers: [String] = []
    private var premiereDate: Date?
    private(set) var backgroundColor: UIColor = .white

    private var premiereDateString: String? {
        guard let premiereDate = self.premiereDate else {
            return nil
        }
        return FormatterHelper.formatDateOnlyDayAndMonth(premiereDate)
    }

    private var directorsString: String {
        self.directors.joined(separator: ", ")
    }

    private var actorsString: String {
        self.actors.joined(separator: ", ")
    }

    private var producersString: String {
        self.producers.joined(separator: ", ")
    }


    var rows: [BlockInfo] {
        var data = [BlockInfo]()
        for block in Blocks.cases {
            switch block {
            case .directors where !self.directorsString.isEmpty:
                let blockInfo = BlockInfo(
                    title: NSLocalizedString("Directors", bundle: .primeSdk, comment: ""),
                    subtitle: self.directorsString
                )
                data.append(blockInfo)
            case .actors where !self.actorsString.isEmpty:
                let blockInfo = BlockInfo(
                    title: NSLocalizedString("Actors", bundle: .primeSdk, comment: ""),
                    subtitle: self.actorsString
                )
                data.append(blockInfo)
            case .premiereDateRussia where self.premiereDateString != nil:
                let blockInfo = BlockInfo(
                    title: NSLocalizedString("PremiereInRussia", bundle: .primeSdk, comment: ""),
                    subtitle: self.premiereDateString ?? ""
                )
                data.append(blockInfo)
            case .producers where !self.producersString.isEmpty:
                let blockInfo = BlockInfo(
                    title: NSLocalizedString("Producers", bundle: .primeSdk, comment: ""),
                    subtitle: self.producersString
                )
                data.append(blockInfo)
            default:
                break
            }
        }

        return data
    }

    init(viewName: String, valueForAttributeID: [String: Any]) throws {
        self.viewName = viewName

        self.directors = valueForAttributeID["directors"] as? [String] ?? []
        self.actors = valueForAttributeID["actors"] as? [String] ?? []
        self.producers = valueForAttributeID["producers"] as? [String] ?? []

        if let dateString = valueForAttributeID["premiere_date"] as? String {
            if let date = Date(string: dateString) {
                if date > Date() {
                    self.premiereDate = date
                } else {
                    self.premiereDate = nil
                }
            }
        } else {
            self.premiereDate = nil
        }

        if
            let backgroundColorString = valueForAttributeID["background_color"] as? String,
            let backgroundColor = UIColor(hex: backgroundColorString)
        {
            self.backgroundColor = backgroundColor
        }
    }
}

struct DetailBookingODPInfoViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    let detailRow = DetailRow.bookingODPInfo

    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    var clubID: String?
    var sdkManager: PrimeSDKManagerProtocol?

    init(viewName: String, valueForAttributeID: [String: Any], sdkManager: PrimeSDKManagerProtocol) throws {
        if let clubID = valueForAttributeID["club_id"] as? String {
            self.clubID = clubID
        }

        self.sdkManager = sdkManager
        self.viewName = viewName
    }

    static func == (lhs: DetailBookingODPInfoViewModel, rhs: DetailBookingODPInfoViewModel) -> Bool {
        lhs.clubID == rhs.clubID
    }
}

// swiftlint:enable file_length
