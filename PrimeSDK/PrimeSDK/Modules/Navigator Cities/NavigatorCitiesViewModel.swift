import Foundation

class NavigatorCityViewModel: ViewModelProtocol, HomeCellViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [
            "title": title as Any
        ]
    }

    var id: String
    var title: String?
    var imageURL: URL?
    var color: UIColor?
    var subtitle: String?

    init(valueForAttributeID: [String: Any]) {
        self.id = valueForAttributeID["id"] as? String ?? ""
        self.title = valueForAttributeID["title"] as? String
        if let imagePath = valueForAttributeID["image_path"] as? String {
            imageURL = URL(string: imagePath)
        }

        if let imageColorString = valueForAttributeID["image_color"] as? String {
            let componentsString = imageColorString.suffix(
                from: imageColorString.index(
                    imageColorString.startIndex,
                    offsetBy: 5
                )
            ).dropLast()

            let components: [String] = String(componentsString).split(separator: ",").map {
                String($0).trimmingCharacters(in: .whitespacesAndNewlines)
            }

            if
                components.count == 4,
                let red = Float(components[0]),
                let green = Float(components[1]),
                let blue = Float(components[2]),
                let alpha = Float(components[3])
            {
                self.color = UIColor(
                    red: CGFloat(red / 255.0),
                    green: CGFloat(green / 255.0),
                    blue: CGFloat(blue / 255.0),
                    alpha: CGFloat(alpha)
                )
            }
        }
    }
}

class NavigatorCitiesViewModel: ViewModelProtocol, ListViewModelProtocol {
    typealias ItemType = NavigatorCityViewModel

    var viewName: String = ""
    var attributes: [String: Any] {
        return [:]
    }

    var allCities: [NavigatorCityViewModel] = []
    var query: String?
    var cities: [NavigatorCityViewModel] {
        return allCities.filter { $0.title?.hasPrefix(query ?? "") == true }
    }

    init(
        name: String,
        valueForAttributeID: [String: Any]
    ) {
        self.viewName = name

        self.allCities = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "city",
            initBlock: { valueForAttributeID, _ in
                NavigatorCityViewModel(valueForAttributeID: valueForAttributeID)
            }
        )
    }

    func addCities(
        valueForAttributeID: [String: Any]
    ) {
        self.allCities += initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "city",
            initBlock: { valueForAttributeID, _ in
                NavigatorCityViewModel(valueForAttributeID: valueForAttributeID)
            }
        )
    }

    func reloadCities(
        valueForAttributeID: [String: Any]
    ) {
        self.allCities = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "city",
            initBlock: { valueForAttributeID, _ in
                NavigatorCityViewModel(valueForAttributeID: valueForAttributeID)
            }
        )
    }


    init(name: String) {
        self.viewName = name
    }
}
