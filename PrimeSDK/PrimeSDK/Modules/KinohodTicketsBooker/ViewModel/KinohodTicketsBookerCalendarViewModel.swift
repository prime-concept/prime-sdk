import Foundation

class KinohodTicketsBookerCalendarViewModel: ListViewModelProtocol {
    typealias ItemType = MovieDayItem

    var days: [DayItem] = []
    var firstDateIndex: Int = 0
    var firstDate = Date()

    var nearestDateString: String {
        guard let nearestDate = nearestDate else {
            return ""
        }
        return FormatterHelper.formatDateOnlyDayAndMonth(nearestDate)
    }

    var nearestDate: Date? {
        return days.first(where: { $0.hasData })?.date
    }

    var selectedIndex: Int = 0
    var selectedDay: DayItem {
        return days[selectedIndex]
    }

    var isDummy = false

    struct MovieDayItem {
        var date: Date
        var movieCount: Int

        init?(
            valueForAttributeID: [String: Any]
        ) {
            guard let dateString = valueForAttributeID["date"] as? String else {
                return nil
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard
                let date = dateFormatter.date(from: dateString),
                let movieCountString = valueForAttributeID["count"] as? String,
                let movieCount = Int(movieCountString)
            else {
                return nil
            }
            self.date = date

            self.movieCount = movieCount
        }
    }

    struct DayItem: Equatable {
        var dayOfWeek: String
        var dayNumber: String
        var month: String

        var date: Date
        var dateString: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }

        var moviesCount: Int
        var hasData: Bool {
            return moviesCount > 0
        }

        static var dummyViewModel = DayItem(
            dayOfWeek: "dayOfWeek",
            dayNumber: "dayNumber",
            month: "month",
            date: Date(),
            moviesCount: 0
        )
    }

    init?(
        valueForAttributeID: [String: Any]
    ) {
        let schedule = getDays(
            listName: "calendar",
            valueForAttributeID: valueForAttributeID
        )
        let sortedSchedule = schedule.sorted(by: { $0.date < $1.date })

        guard
            var firstDate = sortedSchedule.first?.date,
            let lastDate = sortedSchedule.last?.date
        else {
            return nil
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

        var days: [DayItem] = []
        var firstDateIndex = 0
        calendar.enumerateDates(
            startingAfter: startDate,
            matching: midnightComponents,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else {
                return
            }
            if date <= dateEnding {
                if date == firstDate {
                    firstDateIndex = days.count
                }

                let day = calendar.component(.day, from: date)
                let weekdayNumber = calendar.component(.weekday, from: date)
                let month = calendar.component(.month, from: date)

                let movieCount = schedule.first(where: { $0.date == date })?.movieCount ?? 0

                days.append(
                    DayItem(
                        dayOfWeek: calendar.shortWeekdaySymbols[weekdayNumber - 1],
                        dayNumber: "\(day)",
                        month: calendar.shortMonthSymbols[month - 1],
                        date: date,
                        moviesCount: movieCount
                    )
                )
            } else {
                stop = true
            }
        }

        //TODO: Uncomment this if something works really bad on empty schedule films
//        if days.isEmpty {
//            throw PrimeSDKError()
//        }

        self.firstDateIndex = firstDateIndex
        self.firstDate = firstDate
        self.days = days
    }

    init() {
    }

    private func getDays(
        listName: String,
        valueForAttributeID: [String: Any]
    ) -> [MovieDayItem] {
        return self.initItems(
            valueForAttributeID: valueForAttributeID,
            listName: listName,
            initBlock: { valueForAttributeID, _ in
                MovieDayItem(valueForAttributeID: valueForAttributeID)
            }
        )
    }
}
