import Foundation

struct DetailHeaderViewModel: ViewModelProtocol, ListViewModelProtocol, DetailHeaderViewModelProtocol, Equatable {
    typealias ItemType = String

    var viewName: String = ""

    var id: String?
    var title: String?
    var subtitle: String?
    var isFavorite = false
    var isFavoriteAvailable = false
    var startDate: Date?
    var endDate: Date?
    var badge: String?
    var extraBadge: String?
    var distance: String?
    var shouldShowOndaLogo = false
    var status: String?
    var shouldUpdateStatus = false
    var city: String?

    var imagesPath: [String] = []
    var imagePath: String? {
        return imagesPath.first
    }

    var logosPath: [String] = []
    var logo: URL? {
        logosPath.first.flatMap { URL(string: $0) }
    }

    var imagesURL: [URL] {
        if !imagesPath.isEmpty {
            return imagesPath.compactMap { URL(string: $0) }
        }

        return []
    }

    var attributes: [String: Any] {
        return [
            "title": title as Any,
            "subtitle": subtitle as Any,
            "id": id as Any
        ]
    }

    init(
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailImageCarouselHeaderConfigView.Attributes? = nil,
        getDistanceBlock: ((GeoCoordinate?) -> Double?)?,
        isFavoriteAvailable: Bool
    ) {
        self.init(attributes: defaultAttributes)
        self.id = valueForAttributeID["id"] as? String ?? self.id
        self.title = valueForAttributeID["title"] as? String ?? self.title
        self.subtitle = valueForAttributeID["subtitle"] as? String ?? self.subtitle
        self.isFavorite = valueForAttributeID["is_favorite"] as? Bool ?? self.isFavorite
        self.badge = valueForAttributeID["badge"] as? String ?? self.badge
        self.extraBadge = valueForAttributeID["header_badge"] as? String ?? self.extraBadge
        self.isFavoriteAvailable = isFavoriteAvailable
        self.city = valueForAttributeID["city"] as? String

        self.imagesPath = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "images",
            initBlock: { itemValueForAttributeID, _ in
                itemValueForAttributeID["image"] as? String
            }
        )

        if
            let lat = valueForAttributeID["lat"] as? Double,
            let lon = valueForAttributeID["lon"] as? Double,
            let distance = getDistanceBlock?(GeoCoordinate(lat: lat, lng: lon)) {
                self.distance = FormatterHelper.format(distanceInMeters: distance)
        }

        if let dateString = valueForAttributeID["start_date"] as? String {
            self.startDate = Date(string: dateString)
        }

        if let dateString = valueForAttributeID["end_date"] as? String {
            self.endDate = Date(string: dateString)
        }

        self.shouldShowOndaLogo = defaultAttributes?.showOndaLogo ?? false

        self.logosPath = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "logo",
            initBlock: { itemValueForAttributeID, _ in
                itemValueForAttributeID["image"] as? String
            }
        )

        self.subtitle = getSubtitle() ?? self.subtitle
    }

    init() {}

    init(attributes: DetailImageCarouselHeaderConfigView.Attributes?) {
        guard let attributes = attributes else {
            return
        }
        self.title = attributes.title
        self.subtitle = attributes.subtitle
        self.startDate = attributes.startDate
        self.endDate = attributes.endDate
        self.shouldUpdateStatus = attributes.shouldUpdateStatus
    }

    private func getSubtitle() -> String? {
        var formattedDate = FormatterHelper.formatDateInterval(
            from: startDate,
            to: endDate
        ) ?? ""

        if let startDate = startDate, endDate == nil {
            formattedDate = FormatterHelper.formatNewsItem(date: startDate)
        }

        guard let type = subtitle, !type.isEmpty else {
            return "\(formattedDate)"
        }

        guard !formattedDate.isEmpty else {
            return "\(type)"
        }

        return "\(type) · \(formattedDate)"
    }

    func isEqualTo(otherHeader: DetailHeaderViewModelProtocol) -> Bool {
        guard let otherHeader = otherHeader as? DetailHeaderViewModel else {
            return false
        }
        return self == otherHeader
    }
}
