import Foundation

struct HomeMoviePlainCardViewModel: TitledHorizontalListCardViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "id": id
        ]
    }

    var id: String = ""
    var imdbRating: Float?
    var genres: [String] = []
    var title: String?
    var imagePath: String
    var canSalePushkinCard: Bool = false

    private var premiereDate: Date?
    var premiereDateString: String? {
        guard let premiereDate = premiereDate else {
            return nil
        }
        let start = NSLocalizedString("FromC", bundle: .primeSdk, comment: "")
        let dateString = FormatterHelper.formatDateOnlyDayAndMonth(premiereDate)
        return "\(start) \(dateString)"
    }

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: FlatMovieCardConfigView.Attributes? = nil
    ) {
        self.viewName = name
        if let ratingString = valueForAttributeID["imdb_rating"] as? String {
            self.imdbRating = Float(ratingString)
        }
        if let genresArray = valueForAttributeID["genres"] as? [[String: Any]] {
            genres = genresArray.compactMap { $0["name"] as? String }
        } else if let genre = valueForAttributeID["genres"] as? String {
            genres = [genre]
        }

        self.title = valueForAttributeID["title"] as? String ?? defaultAttributes?.title ?? ""
        self.imagePath = valueForAttributeID["image_path"] as? String ?? defaultAttributes?.imagePath ?? ""
        self.id = valueForAttributeID["id"] as? String ?? defaultAttributes?.id ?? ""
        if let dateString = valueForAttributeID["premiere_date"] as? String, !dateString.isEmpty {
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
        if let canSaleString = valueForAttributeID["can_sale_pushkin_card"] as? String {
            self.canSalePushkinCard = NSString(string: canSaleString).boolValue
        }
    }

    init(
         title: String
    ) {
         self.viewName = ""
         self.title = title
         self.imagePath = ""
         self.genres = ["genre"]
     }

     static var dummyViewModel = HomeMoviePlainCardViewModel(
         title: "Loading"
     )

    var genresString: String {
        let text = genres.first ?? ""
        return text.uppercased()
    }
}
