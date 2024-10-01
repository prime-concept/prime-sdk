import Foundation
import PromiseKit

protocol ChangeCityPresenterProtocol: AnyObject {
    func didLoad()
    func refresh()
    func didSelect(section: Int, item: Int)
    func changeQuery(toQuery: String?)
    func apply()
    func willDisappear()
}

class ChangeCityPresenter: ChangeCityPresenterProtocol {
    weak var view: ChangeCityViewProtocol?
    private var viewName: String
    private var configuration: Configuration
    private var apiService: APIServiceProtocol
    private var sdkManager: PrimeSDKManagerProtocol
    private var locationService: LocationServiceProtocol

    private var selectedCityID: String? {
        return sdkManager.changeCityDelegate?.getSelectedCityID()
    }

    private var defaultCityID: String {
        return sdkManager.changeCityDelegate?.getDefaultCityID() ?? "1"
    }

    private var viewModel: ChangeCityListViewModel?

    init(
        view: ChangeCityViewProtocol,
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
    }

    func didLoad() {
        sdkManager.analyticsDelegate?.screenOpened(viewName: "change-city", source: nil)
    }

    func refresh() {
        guard
            let configView = configuration.views[viewName] as? ChangeCityConfigView
        else {
            return
        }

        let viewModel = ChangeCityListViewModel(
            name: configView.name,
            valueForAttributeID: [:],
            defaultAttributes: configView.attributes
        )
        self.viewModel = viewModel
        self.view?.update(viewModel: viewModel)

        let actionName = configView.actions.load
        guard let loadAction = configuration.actions[actionName] as? LoadConfigAction else {
            return
        }

        loadAction.request.inject(action: loadAction.name, viewModel: nil)
        loadAction.response.inject(action: loadAction.name, viewModel: nil)

        if let cachedJSON = sdkManager.apiDelegate?.getCachedResponse(configRequest: loadAction.request),
            let cachedPromise = loadAction.response.deserializer?.deserialize(json: cachedJSON) {
            self.proccessAndUpdateView(from: cachedPromise, for: configView)
        }

        let apiServicePromise = apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise
        self.proccessAndUpdateView(from: apiServicePromise, for: configView)
    }

    private func proccessAndUpdateView(
        from promise: Promise<DeserializedViewMap>,
        for configView: ChangeCityConfigView
    ) {
        promise.then { [weak self] deserializedViewMap -> Promise<GeoCoordinate> in
            guard let self = self else {
                //TODO: Make it some king of normal error
                throw CityChangeError.noSelf
            }

            let viewModel = ChangeCityListViewModel(
                name: configView.name,
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                defaultAttributes: configView.attributes
            )
            self.viewModel = viewModel

            if let selectedCityID = self.selectedCityID {
                self.selectCity(withID: selectedCityID, informDelegate: false)
                throw CityChangeError.hasDefaultCity
            } else {
                self.view?.update(viewModel: viewModel)
                return self.locationService.getLocation()
            }
        }.done { [weak self] _ in
            let minCity = self?.viewModel?.cities.min(
                by: {
                    let distance1 = self?.locationService.distance(to: $0.coordinate)
                    let distance2 = self?.locationService.distance(to: $1.coordinate)

                    if
                        let distance1 = distance1,
                        let distance2 = distance2
                    {
                        return distance1 < distance2
                    }
                    if distance1 != nil {
                        return true
                    }
                    return false
                }
            )
            if
                let minCity = minCity,
                self?.locationService.distance(to: minCity.coordinate) != nil
            {
                self?.selectCity(withID: minCity.id)
            }
        }.catch { [weak self] error in
            if
                error is LocationError,
                let empty = self?.viewModel?.cities.isEmpty,
                !empty
            {
                if let defaultCityID = self?.defaultCityID {
                    self?.selectCity(withID: defaultCityID)
                } else {
                    self?.selectCity(withID: "1")
                }
            }
        }
    }

    private func selectCity(withID: String, informDelegate: Bool = true) {
        var oldCityName: String?
        var newCityName: String?
        guard var viewModel = viewModel else {
            return
        }

        if let index = viewModel.cities.firstIndex(where: { $0.id == withID }) {
            if let selectedIndex = viewModel.cities.firstIndex(where: { $0.isSelected }) {
                viewModel.cities[selectedIndex].isSelected = false
                oldCityName = viewModel.cities[selectedIndex].name
            }
            newCityName = viewModel.cities[index].name
            viewModel.cities[index].isSelected = true
            self.viewModel = viewModel
            view?.update(viewModel: viewModel)
            if let oldCityName = oldCityName, let newCityName = newCityName {
                sdkManager.analyticsDelegate?.cityChanged(oldCityName: oldCityName, newCityName: newCityName)
            }
            if informDelegate {
                sdkManager.changeCityDelegate?.cityChanged(toCity: withID, title: viewModel.cities[index].name)
            }
        }
    }

    func didSelect(section: Int, item: Int) {
        guard let viewModel = viewModel else {
            return
        }

        let selectID = viewModel.sections[section].cities[item].id

        selectCity(withID: selectID, informDelegate: false)
    }

    func changeQuery(toQuery: String?) {
        viewModel?.query = toQuery
        if let viewModel = viewModel {
            view?.update(viewModel: viewModel)
        }
    }

    func apply() {
        guard let selectedCity = viewModel?.cities.first(where: { $0.isSelected }) else {
            view?.close()
            return
        }

        sdkManager.changeCityDelegate?.cityCoordinateChanged(toCoordinate: selectedCity.coordinate)
        sdkManager.changeCityDelegate?.cityChanged(toCity: selectedCity.id, title: selectedCity.name)
        view?.close()
    }

    func willDisappear() {
        guard let selectedCity = viewModel?.cities.first(where: { $0.isSelected }) else {
            view?.close()
            return
        }
        sdkManager.changeCityDelegate?.cityChanged(toCity: selectedCity.id, title: selectedCity.name)
        sdkManager.changeCityDelegate?.cityChangeFinished()
    }

    enum CityChangeError: Error {
        case hasDefaultCity
        case noSelf
    }
}
