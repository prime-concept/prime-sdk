import Foundation

class KinohodSearchViewModel: ViewModelProtocol, ListViewModelProtocol {
    var viewName: String

    var attributes: [String: Any] {
        return [:]
    }

    typealias ItemType = SearchItem

    var query: String?

    var movies: [HomeMoviePlainCardViewModel] = []
    var cinemas: [CinemaCardViewModel] = []
    var items: [SearchItem] = []

    class SearchItem: SubviewContainerViewModelProtocol {
        var movie: HomeMoviePlainCardViewModel?
        var cinema: CinemaCardViewModel?

        enum ItemType: String {
            case cinema, movie
        }
        var type: ItemType

        init?(
            configView: KinohodSearchConfigView.Attributes,
            valueForAttributeID: [String: Any],
            sdkManager: PrimeSDKManagerProtocol,
            configuration: Configuration
        ) {
            guard
                let typeString = valueForAttributeID["type"] as? String,
                let type = ItemType(rawValue: typeString)
            else {
                return nil
            }

            self.type = type

            switch type {
            case .cinema:
                self.cinema = getCinema(
                    configView: configView,
                    valueForAttributeID: valueForAttributeID,
                    sdkManager: sdkManager,
                    configuration: configuration
                )
            case .movie:
                self.movie = getMovie(
                    configView: configView,
                    valueForAttributeID: valueForAttributeID,
                    sdkManager: sdkManager,
                    configuration: configuration
                )
            }
        }

        func getCinema(
            configView: KinohodSearchConfigView.Attributes,
            valueForAttributeID: [String: Any],
            sdkManager: PrimeSDKManagerProtocol,
            configuration: Configuration
        ) -> CinemaCardViewModel? {
            guard let cinemaCardConfigView = configuration.views[configView.cinema] as? CinemaCardConfigView else {
                return nil
            }

            let cinemaValues = KinohodSearchViewModel.SearchItem.getValuesForSubview(
                valueForAttributeID: valueForAttributeID,
                subviewName: configView.cinema
            )

            let cinema = CinemaCardViewModel(
                viewName: configView.cinema,
                sourceName: "search",
                valueForAttributeID: cinemaValues,
                defaultAttributes: cinemaCardConfigView.attributes,
                sdkManager: sdkManager,
                configuration: configuration
            )

            return cinema
        }

        func getMovie(
            configView: KinohodSearchConfigView.Attributes,
            valueForAttributeID: [String: Any],
            sdkManager: PrimeSDKManagerProtocol,
            configuration: Configuration
        ) -> HomeMoviePlainCardViewModel? {
            guard let movieCardConfigView = configuration.views[configView.movie] as? FlatMovieCardConfigView else {
                return nil
            }

            let movieValues = KinohodSearchViewModel.SearchItem.getValuesForSubview(
                valueForAttributeID: valueForAttributeID,
                subviewName: configView.movie
            )

            let movie = HomeMoviePlainCardViewModel(
                name: configView.movie,
                valueForAttributeID: movieValues,
                defaultAttributes: movieCardConfigView.attributes
            )

            return movie
        }
    }

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: KinohodSearchConfigView.Attributes,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration,
        query: String?
    ) {
        self.viewName = name
        self.query = query
        self.items = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "search",
            initBlock: { valueForAttributeID, _ in
                SearchItem(
                    configView: defaultAttributes,
                    valueForAttributeID: valueForAttributeID,
                    sdkManager: sdkManager,
                    configuration: configuration
                )
            }
        )
        movies = []
        cinemas = []
        for item in items {
            switch item.type {
            case .movie:
                if let movie = item.movie {
                    movies += [movie]
                }
            case .cinema:
                if let cinema = item.cinema {
                    cinemas += [cinema]
                }
            }
        }
    }
}
