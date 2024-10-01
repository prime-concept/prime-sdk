import SwiftyJSON

struct DetailOnlineCinemaListViewModel: DetailBlockViewModel, ViewModelProtocol, Equatable {
    var viewName: String

    var cinemas: [DetailOnlineCinemaViewModel]
    var backgroundColor: UIColor = .white

    var attributes: [String: Any] {
        return [:]
    }

    let detailRow = DetailRow.onlineCinemaList

    init?(
        viewName: String,
        valueForAttributeID: [String: Any]
    ) {
        self.viewName = viewName

        if
            let backgroundColorString = valueForAttributeID["background_color"] as? String,
            let backgroundColor = UIColor(hex: backgroundColorString)
        {
            self.backgroundColor = backgroundColor
        }

        self.cinemas = []
        if let onlinesArray = valueForAttributeID["onlines"] as? [[String: Any]] {
            for online in onlinesArray {
                if let type = online["type"] as? String, type == "onlines",
                    let attributes = online["attributes"] as? [String: Any],
                    let cinemaViewModel = DetailOnlineCinemaViewModel(dict: attributes) {
                    cinemas += [cinemaViewModel]
                }
            }
        }
    }
}

struct DetailOnlineCinemaViewModel: Equatable {
    let types = ["AVOD", "SVOD", "TVOD", "EST"]

    enum Price: Equatable {
        case value(Value)
        case provider(Provider)

        init?(dict: [String: Any]) {
            guard let type = dict["type"] as? String else {
                return nil
            }

            if let provider = dict["protocol_type", String.self],
               provider == "kinopoisk" {
                guard let logo = UIImage(named: "yandex_plus_logo", in: .primeSdk, compatibleWith: nil) else {
                    fatalError("Could not find logo for \(provider), file: \("yandex_plus_logo")")
                }
                self = .provider(.init(type: type, image: logo))
                return
            }

            guard let price = dict["price"] as? Int,
                let currency = dict["currency"] as? String,
                let qualities = dict["quality"] as? [String]
            else {
                return nil
            }

            self = .value(
                .init(
                    type: type,
                    price: price,
                    currency: currency,
                    qualities: qualities
                )
            )
        }

        struct Value: Equatable {
            var type: String
            var price: Int
            var currency: String
            var qualities: [String]
        }

        struct Provider: Equatable {
            var type: String
            let image: UIImage
        }
    }

    var typeGroupedPricesList: [TypeGroupedPricesViewModel] = []

    var title: String
    var imagePath: String
    var link: String
    private var prices: [Price]

    init?(dict: [String: Any]) {
        guard let title = dict["protocol_name"] as? String,
            let link = dict["ref_link"] as? String,
            let prices = dict["prices"] as? [[String: Any]],
            let icon = dict["icon"] as? String
        else {
            return nil
        }

        self.title = title
        self.link = link
        self.prices = prices.compactMap { priceDict in
            var typedDict = priceDict
            typedDict["protocol_type"] = dict["protocol_type"]
            return Price(dict: typedDict)
        }

        self.imagePath = icon

        self.typeGroupedPricesList = types.compactMap { TypeGroupedPricesViewModel(prices: self.prices, type: $0) }
    }
}

struct TypeGroupedPricesViewModel: Equatable {
    var type: String

    var title: String {
        switch type {
        case "AVOD":
            return "БЕСПЛАТНО"
        case "SVOD":
            return "ПОДПИСКА"
        case "TVOD":
            return "АРЕНДА"
        case "EST":
            return "ПОКУПКА"
        default:
            return "ДРУГОЕ"
        }
    }

    var isRent: Bool {
        self.type == "TVOD"
    }

    var isPurhase: Bool {
        self.type == "EST"
    }

    var prices: [SinglePriceViewModel] = []

    init?(prices: [DetailOnlineCinemaViewModel.Price], type: String) {
        self.type = type
        let filtered = prices.filter { $0.type == type }
        for price in filtered {
            self.prices += price.qualities.compactMap { SinglePriceViewModel(price: price, quality: $0) }
        }
        if self.prices.isEmpty {
            return nil
        }
    }
}

struct SinglePriceViewModel: Equatable {
    var price: Int?
    var currency: String?
    var quality: String
    var type: String
    var logo: UIImage?

    var displayCurrency: String? {
        switch currency {
        case "RUB":
            return "₽"
        case "USD":
            return "$"
        case "EUR":
            return "€"
        default:
            return nil
        }
    }

    init?(price: DetailOnlineCinemaViewModel.Price, quality: String) {
        guard price.qualities.contains(quality) else {
            return nil
        }

        if case let .value(value) = price {
            self.price = value.price
            self.currency = value.currency
        }
        if case let .provider(provider) = price {
            self.logo = provider.image
        }
        self.type = price.type
        self.quality = quality
    }
}

fileprivate extension DetailOnlineCinemaViewModel.Price {
    var type: String {
        switch self {
        case .provider(let provider):
            return provider.type
        case .value(let value):
            return value.type
        }
    }

    var qualities: [String] {
        switch self {
        case .provider:
            return ["N/A"]
        case .value(let value):
            return value.qualities
        }
    }
}
