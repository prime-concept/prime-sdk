import Foundation

struct DetailBookingGuest: Equatable {
    var name: String
    var email: String
}

class DetailBookingInfoViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    var viewName: String
    let detailRow: DetailRow = .bookingInfo

    var attributes: [String: Any] {
        return [:]
    }

    var visitDateTimeUTC = Date()

    var dateString: String = ""
    var newDateString: String? {
        guard
            let newDate = self.newDate,
            let newTime = self.newTime
        else {
            return nil
        }
        return "\(newDate) \(newTime)"
    }

    var displayingDateString: String {
        if
            self.bookingStatus != "IN_CHANGE",
            let newDateString = self.newDateString
        {
            return newDateString
        } else {
            return dateString
        }
    }

    static func getString(fromDateString dateString: String) -> String {
        let datePrefix = String(dateString.prefix(10))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let timeSuffix = String(dateString.suffix(5))
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        if let date = dateFormatter.date(from: datePrefix) {
            return "\(formatter.string(from: date)) \(timeSuffix)"
        } else {
            return dateString
        }
    }

    var id: String
    var bookingNumber: String = ""
    var guests: [DetailBookingGuest] = []
    private var optionsList: [String] = []
    var availableStatuses: [String] = []
    var options: String {
        return optionsList.joined(separator: ", ")
    }

    var cancellationPolicyURL: URL? {
        sdkManager.bookingDelegate?.bookingPrivacyPolicyURL
    }

    var note: String = ""
    var bookingStatus: String = ""
    var backgroundColor: UIColor = .white

    var newDate: String?
    var newTime: String?
    var clubName: String = ""
    var clubID: String = ""

    var loadAction: LoadConfigAction?

    var sdkManager: PrimeSDKManagerProtocol

    init?(
        viewName: String,
        valueForAttributeID: [String: Any],
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        guard
            let configView = configuration.views[viewName] as? DetailBookingInfoConfigView
        else {
            return nil
        }

        self.viewName = viewName
        self.id = valueForAttributeID["id"] as? String ?? ""
        if
            let backgroundColorString = valueForAttributeID["background_color"] as? String,
            let backgroundColor = UIColor(hex: backgroundColorString)
        {
            self.backgroundColor = backgroundColor
        }

        self.sdkManager = sdkManager

        if let loadActionName = configView.actions.load {
            self.loadAction = configuration.actions[loadActionName] as? LoadConfigAction
        }
    }

    func update(
        valueForAttributeID: [String: Any]
    ) {
        self.id = valueForAttributeID["id"] as? String ?? ""
        self.note = valueForAttributeID["note"] as? String ?? ""
        self.bookingNumber = valueForAttributeID["booking_number"] as? String ?? ""

        self.guests = (valueForAttributeID["guests"] as? [[String: Any]])?.map {
            DetailBookingGuest(
                name: $0["name"] as? String ?? "",
                email: $0["email"] as? String ?? ""
            )
        } ?? []

        self.optionsList = (valueForAttributeID["options"] as? [[String: Any]])?.compactMap {
            $0["name"] as? String
        } ?? []

        self.availableStatuses = valueForAttributeID["available_statuses"] as? [String] ?? []

        let status = valueForAttributeID["booking_status"] as? String ?? ""
        let canceledStatus = NSLocalizedString("BookingCanceled", bundle: .primeSdk, comment: "")
        self.bookingStatus = status.lowercased() == "cancel" ? canceledStatus : status

        if let bookingDateString = valueForAttributeID["visit_date"] as? String {
            self.dateString = DetailBookingInfoViewModel.getString(fromDateString: bookingDateString)
        }

        self.newTime = valueForAttributeID["new_time"] as? String
        if
            let newDateString = valueForAttributeID["new_date"] as? String,
            let date = Date(string: newDateString)
        {
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .medium

            self.newDate = formatter.string(from: date)
        }
        self.clubName = valueForAttributeID["club_name"] as? String ?? ""
        self.clubID = valueForAttributeID["club_id"] as? String ?? ""

        if let dateUTCString = valueForAttributeID["visit_date_utc"] as? String,
           let dateUTC = Date(string: dateUTCString) {
            self.visitDateTimeUTC = dateUTC
        }
    }

    static func == (lhs: DetailBookingInfoViewModel, rhs: DetailBookingInfoViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}
