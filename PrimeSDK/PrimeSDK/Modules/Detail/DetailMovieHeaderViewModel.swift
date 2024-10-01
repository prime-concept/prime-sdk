import Foundation

struct DetailMovieHeaderViewModel: ViewModelProtocol, ListViewModelProtocol, DetailHeaderViewModelProtocol, Equatable {
    func isEqualTo(otherHeader: DetailHeaderViewModelProtocol) -> Bool {
        guard let otherHeader = otherHeader as? DetailMovieHeaderViewModel else {
            return false
        }
        return self == otherHeader
    }

    typealias ItemType = TrailerSource

    var viewName: String = ""

    var title: String?
    var genres: [String] = []
    var ageRestriction: String?
    var imdbRating: Float?
    var duration: Int?
    var countries: [String] = []
    var trailers: [TrailerSource] = []
    var imagePath: String?
    var backgroundColor: UIColor = .white
    var canSalePushkinCard: Bool = false

    private var genresString: String {
        let text = genres.first ?? ""
        return text.uppercased()
    }

    var subtitle: String? {
        if genresString.isEmpty {
            return "\(ageRestriction ?? "")"
        }

        return "\(genresString) · \(ageRestriction ?? "")"
    }

    private var countriesString: String {
        return countries.joined(separator: ", ")
    }

    var bottomText: String? {
        if (durationString ?? "").isEmpty {
            return "\(countriesString)"
        }

        return "\(countriesString) · \(durationString ?? "")"
    }

    var durationString: String? {
        guard let duration = duration else {
            return nil
        }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated

        let formattedString = formatter.string(from: TimeInterval(duration * 60))
        return formattedString
    }

    var trailerPath: String? {
        return trailers.first(where: { $0.duration != "0" })?.url
    }

    struct TrailerSource: Equatable {
        var ext: String
        var uuid: String
        var filename: String
        var contentType: String
        var duration: String

        //TODO: Remove this when it's time (should intelligently handle iterator ranges in parser)
        //То есть присваиваем всем без исключения итераторам с одним и тем же id одинаковые рейнджи
        var baseURL: String = "https://kinohod.ru/o"

        var crop: String {
            return "\(uuid[0...1])/\(uuid[2...3])/\(filename).\(ext)"
        }

        var url: String {
            return "\(baseURL)/\(crop)"
        }

        init?(valueForAttributeID: [String: Any]) {
            if
                let ext = valueForAttributeID["extension"] as? String,
                let uuid = valueForAttributeID["uuid"] as? String,
                let filename = valueForAttributeID["filename"] as? String,
                let contentType = valueForAttributeID["content_type"] as? String,
                let duration = valueForAttributeID["duration"] as? String
            {
                self.ext = ext
                self.uuid = uuid
                self.filename = filename
                self.contentType = contentType
                self.duration = duration
            } else {
                return nil
            }
        }
    }


    init(
        valueForAttributeID: [String: Any],
        defaultAttributes: DetailMovieHeaderConfigView.Attributes? = nil
    ) {
        self.init(attributes: defaultAttributes)
        self.title = valueForAttributeID["title"] as? String ?? self.title

        if let genresArray = valueForAttributeID["genres"] as? [[String: Any]] {
            self.genres = genresArray.compactMap { $0["name"] as? String }
        } else if let genresArray = valueForAttributeID["genres"] as? [String] {
            self.genres = genresArray
        } else {
            self.genres = []
        }

        if let countriesArray = valueForAttributeID["countries"] as? [String] {
            self.countries = countriesArray
        } else {
            self.countries = ListItemParser().initItems(
                valueForAttributeID: valueForAttributeID,
                listName: "countries",
                initBlock: {
                    valueForAttributeID, _ in
                    valueForAttributeID[""] as? String
                }
            )
        }

        self.ageRestriction = valueForAttributeID["age_restriction"] as? String

        self.imagePath = valueForAttributeID["image"] as? String

        if let ratingString = valueForAttributeID["imdb_rating"] as? String {
            self.imdbRating = Float(ratingString)
        }

        if let durationString = valueForAttributeID["duration"] as? String {
            self.duration = Int(durationString)
        }

        self.trailers = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "trailers",
            initBlock: {
                valueForAttributeID, _ in
                TrailerSource(valueForAttributeID: valueForAttributeID)
            }
        )

        if
            let backgroundColorString = valueForAttributeID["background_color"] as? String,
            let backgroundColor = UIColor(hex: backgroundColorString)
        {
            self.backgroundColor = backgroundColor
        }

        if let canSaleString = valueForAttributeID["can_sale_pushkin_card"] as? String {
            self.canSalePushkinCard = NSString(string: canSaleString).boolValue
        }
    }

    init() {}

    init(attributes: DetailMovieHeaderConfigView.Attributes?) {
        guard let attributes = attributes else {
            return
        }
        self.title = attributes.title
    }

    var attributes: [String: Any] {
        return [
            "title": title as Any
        ]
    }
}

