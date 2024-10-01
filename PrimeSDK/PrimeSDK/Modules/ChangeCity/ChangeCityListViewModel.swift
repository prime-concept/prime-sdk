import Foundation

struct ChangeCityListViewModel: ViewModelProtocol {
    var viewName: String = ""
    var attributes: [String: Any] = [:]

    var title: String = ""
    var hereTitle: String = ""
    var searchResultsTitle: String = ""

    var cities: [City] = []

    var query: String?

    struct Section {
        var title: String
        var cities: [City]

        init(title: String, cities: [City]) {
            self.title = title
            self.cities = cities
        }
    }

    struct City {
        let name: String
        var isSelected: Bool
        let id: String
        let coordinate: GeoCoordinate

        init(name: String, isSelected: Bool) {
            self.name = name
            self.isSelected = isSelected
            self.id = "1"
            self.coordinate = GeoCoordinate(lat: 0, lng: 0)
        }

        init?(valueForAttributeID: [String: Any]) {
            name = valueForAttributeID["name"] as? String ?? ""
            id = valueForAttributeID["id"] as? String ?? ""

            let doubleLat = valueForAttributeID["lat"] as? Double
            let stringLat = Double(valueForAttributeID["lat"] as? String ?? "")
            let candidateLat = doubleLat ?? stringLat
            guard
                let lat = candidateLat
            else {
                return nil
            }

            let doubleLon = valueForAttributeID["lon"] as? Double
            let stringLon = Double(valueForAttributeID["lon"] as? String ?? "")
            let candidateLon = doubleLon ?? stringLon
            guard
                let lon = candidateLon
            else {
                return nil
            }

            coordinate = GeoCoordinate(lat: lat, lng: lon)
            isSelected = false
        }
    }

    private func getAlphabeticSections() -> [Section] {
        let groupedSections: [Section] = cities.reduce(
            [], { res, city in
                var res = res
                if res.last?.cities.first?.name.first == city.name.first {
                    res[res.count - 1].cities += [city]
                } else {
                    res += [
                        Section(
                            title: String(city.name.first ?? "A"),
                            cities: [city]
                        )
                    ]
                }
                return res
            }
        )
        return groupedSections
    }

    private func getSection(query: String) -> Section {
        let queryCities = cities.filter { city in
            city.name.prefix(query.count) == query
        }
        return Section(title: "\(searchResultsTitle) \(query)", cities: queryCities)
    }

    var sections: [Section] {
        var res: [Section] = []

        if let query = query {
            res += [getSection(query: query)]
        } else {
            let selectedCities = cities.filter { $0.isSelected }
            if !selectedCities.isEmpty {
                res += [Section(title: hereTitle, cities: selectedCities)]
            }
            res += getAlphabeticSections()
        }

        return res
    }

    init(cities: [City]) {
        self.cities = cities.sorted(by: { $0.name < $1.name })
    }

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: ChangeCityConfigView.Attributes? = nil
    ) {
        self.viewName = name
        self.hereTitle = defaultAttributes?.hereTitle ?? self.hereTitle
        self.title = defaultAttributes?.title ?? self.title
        self.searchResultsTitle = defaultAttributes?.searchResultsTitle ?? self.searchResultsTitle
        cities = getCities(valueForAttributeID: valueForAttributeID)
    }
}

extension ChangeCityListViewModel: ListViewModelProtocol {
    typealias ItemType = ChangeCityListViewModel.City

    func getCities(
        valueForAttributeID: [String: Any]
    ) -> [ChangeCityListViewModel.City] {
        return initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "city",
            initBlock: { itemValueForAttrubuteID, _ in
                ChangeCityListViewModel.City(
                    valueForAttributeID: itemValueForAttrubuteID
                )
            }
        )
    }
}
