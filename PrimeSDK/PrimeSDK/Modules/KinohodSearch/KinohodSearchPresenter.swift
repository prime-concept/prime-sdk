import Foundation

protocol KinohodSearchPresenterProtocol: AnyObject {
    func changeQuery(toQuery query: String?)
    var loadingViewModel: KinohodSearchViewModel? { get }
    func didSelectMovie(movie: HomeMoviePlainCardViewModel)
    func didSelectCinema(cinema: CinemaCardViewModel)
}

class KinohodSearchPresenter: KinohodSearchPresenterProtocol {
    weak var view: KinohodSearchViewProtocol?
    private var viewName: String
    private var configuration: Configuration
    private var apiService: APIServiceProtocol
    private var sdkManager: PrimeSDKManagerProtocol
    private var locationService: LocationServiceProtocol

    private var viewModel: KinohodSearchViewModel?

    private var currentCancelToken: (() -> Void)?

    lazy var loadingViewModel: KinohodSearchViewModel? = {
        getDummySearchViewModel()
    }()

    init(
        view: KinohodSearchViewProtocol,
        viewName: String,
        configuration: Configuration,
        apiService: APIServiceProtocol,
        locationService: LocationServiceProtocol,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.view = view
        self.viewName = viewName
        self.configuration = configuration
        self.apiService = apiService
        self.locationService = locationService
        self.sdkManager = sdkManager

        if let configView = configuration.views[viewName] as? KinohodSearchConfigView {
            self.viewModel = KinohodSearchViewModel(
                name: viewName,
                valueForAttributeID: [:],
                defaultAttributes: configView.attributes,
                sdkManager: sdkManager,
                configuration: configuration,
                query: nil
            )
        }
    }

    private func getDummySearchViewModel() -> KinohodSearchViewModel? {
        guard let configView = configuration.views[viewName] as? KinohodSearchConfigView else {
            return nil
        }
        let viewModel = KinohodSearchViewModel(
            name: viewName,
            valueForAttributeID: [:],
            defaultAttributes: configView.attributes,
            sdkManager: sdkManager,
            configuration: configuration,
            query: nil
        )
        viewModel.cinemas = [
            CinemaCardViewModel.dummyViewModel,
            CinemaCardViewModel.dummyViewModel,
            CinemaCardViewModel.dummyViewModel,
            CinemaCardViewModel.dummyViewModel
        ]
        viewModel.movies = [
            HomeMoviePlainCardViewModel.dummyViewModel,
            HomeMoviePlainCardViewModel.dummyViewModel,
            HomeMoviePlainCardViewModel.dummyViewModel,
            HomeMoviePlainCardViewModel.dummyViewModel
        ]
        return viewModel
    }

    func changeQuery(toQuery query: String?) {
        guard let query = query else {
            currentCancelToken?()
            viewModel?.items = []
            viewModel?.movies = []
            viewModel?.cinemas = []
            self.view?.setLoading(isLoading: false)
            if let viewModel = viewModel {
                view?.update(viewModel: viewModel)
            }
            return
        }
        if query.count < 2 {
            currentCancelToken?()
            viewModel?.items = []
            viewModel?.movies = []
            viewModel?.cinemas = []
            self.view?.setLoading(isLoading: false)
            if let viewModel = viewModel {
                view?.update(viewModel: viewModel)
            }
            return
        }
        refresh(query: query)
    }

    func refresh(query: String) {
        getLocationThen { [weak self] coordinates in
            self?.search(query: query, coordinates: coordinates)
        }
    }

    func didSelectCinema(cinema: CinemaCardViewModel) {
        let configView = configuration.views[cinema.viewName]

        guard
            let cellConfigView = configView as? CinemaCardConfigView,
            let openActionName = cellConfigView.actions.tap,
            let openAction = configuration.actions[openActionName] as? OpenModuleConfigAction
        else {
            return
        }

        sdkManager.analyticsDelegate?.searchResultChosen(type: "cinema", id: cinema.id, text: viewModel?.query ?? "")

        view?.open(model: cinema, action: openAction, config: configuration, sdkManager: sdkManager)
    }

    func didSelectMovie(movie: HomeMoviePlainCardViewModel) {
        let configView = configuration.views[movie.viewName]

        guard
            let cellConfigView = configView as? FlatMovieCardConfigView,
            let openAction = configuration.actions[cellConfigView.actions.tap] as? OpenModuleConfigAction
        else {
            return
        }

        sdkManager.analyticsDelegate?.searchResultChosen(type: "movie", id: movie.id, text: viewModel?.query ?? "")

        view?.open(model: movie, action: openAction, config: configuration, sdkManager: sdkManager)
    }

    private func search(query: String, coordinates: GeoCoordinate? = nil) {
        guard
            let configView = configuration.views[viewName] as? KinohodSearchConfigView
        else {
            return
        }

        let actionName = configView.actions.load
        guard let loadAction = configuration.actions[actionName] as? LoadConfigAction else {
            return
        }

        view?.setLoading(isLoading: true)

        currentCancelToken?()

        DataStorage.shared.set(value: query, for: "query", in: actionName)

        updateLocationHeaders(coordinates)

        loadAction.request.inject(action: loadAction.name, viewModel: viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: viewModel)

        let request = apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        )
        currentCancelToken = request.cancel

        request.promise.done { [weak self] deserializedViewMap in
            guard let self = self else {
                return
            }
            let viewModel = KinohodSearchViewModel(
                name: configView.name,
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                defaultAttributes: configView.attributes,
                sdkManager: self.sdkManager,
                configuration: self.configuration,
                query: query
            )

            if viewModel.cinemas.isEmpty && viewModel.movies.isEmpty {
                self.sdkManager.analyticsDelegate?.searchNotFound(text: query)
            }

            self.view?.setLoading(isLoading: false)
            self.view?.update(viewModel: viewModel)
        }.cauterize()
    }

    private func updateLocationHeaders(_ coordinate: GeoCoordinate?) {
        guard let configView = configuration.views[viewName] as? KinohodSearchConfigView else {
            return
        }

        let loadAction = configView.actions.load

        if let coordinate = coordinate {
            let lat = String(describing: coordinate.latitude)
            let lon = String(describing: coordinate.longitude)

            DataStorage.shared.set(value: lat, for: "lat", in: loadAction)
            DataStorage.shared.set(value: lon, for: "lon", in: loadAction)
        } else {
            DataStorage.shared.set(value: nil, for: "lat", in: loadAction)
            DataStorage.shared.set(value: nil, for: "lon", in: loadAction)
        }
    }

    private func getLocationThen(_ completion: @escaping (GeoCoordinate?) -> Void) {
        locationService.getLocation().done { coordinate in
            completion(coordinate)
        }.catch { _ in
            completion(nil)
        }
    }
}
