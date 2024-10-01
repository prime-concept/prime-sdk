import Foundation
import SwiftyJSON

class KinohodTicketsBookerConfigView: ConfigView {
    struct Attributes {
        var movie: String
        var noDataText: String
        var cinema: String
        var supportPagination: Bool = false

        init(json: JSON) {
            self.movie = json["movie"].stringValue
            self.noDataText = json["no_data_text"].stringValue
            self.cinema = json["cinema"].stringValue
            self.supportPagination = json["support_pagination"].bool ?? false
        }
    }
    var attributes: Attributes

    struct Actions {
        var loadCalendar: String
        var load: String
        var search: String

        init(json: JSON) {
            self.loadCalendar = json["load_calendar"].stringValue
            self.load = json["load"].stringValue
            self.search = json["search"].stringValue
        }
    }
    var actions: Actions

    struct AdBanner {
        var name: String
        var position: Int

        init(json: JSON) {
            self.name = json["name"].stringValue
            self.position = json["position"].intValue
        }
    }
    var ads: [AdBanner]

    override init(json: JSON) {
        actions = Actions(json: json["actions"])
        attributes = Attributes(json: json["attributes"])
        ads = json["ads"].arrayValue.map { AdBanner(json: $0) }
        super.init(json: json)
    }
}
