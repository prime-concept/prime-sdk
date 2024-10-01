import Foundation

struct MoviesPopularityChartItemViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "id": id
        ]
    }

    var id: String = ""
    var genres: [String] = []
    var genresString: String {
        let text = genres.first ?? ""
        return text.uppercased()
    }
    var title: String
    var imagePath: String
    var countLooked: Int = 0
    var countLookedTotal: Int = 1

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: PopularityChartRowConfigView.Attributes? = nil
    ) {
        self.viewName = name
        if let genresArray = valueForAttributeID["genres"] as? [[String: Any]] {
            genres = genresArray.compactMap { $0["name"] as? String }
        } else {
            genres = []
        }

        self.title = valueForAttributeID["title"] as? String ?? defaultAttributes?.title ?? ""
        self.imagePath = valueForAttributeID["image_path"] as? String ?? defaultAttributes?.imagePath ?? ""
        self.id = valueForAttributeID["id"] as? String ?? defaultAttributes?.id ?? ""
        if let countLookedStr = valueForAttributeID["countLooked"] as? String {
            countLooked = Int(countLookedStr) ?? 0
        }
    }

    init(
         title: String
    ) {
        self.viewName = ""
        self.title = title
        self.imagePath = ""
        self.countLooked = 0
        self.genres = [""]
     }

     static var dummyViewModel = MoviesPopularityChartItemViewModel(
         title: "Loading"
     )
}
