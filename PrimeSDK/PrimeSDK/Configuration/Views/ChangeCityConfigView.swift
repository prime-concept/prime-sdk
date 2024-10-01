import Foundation
import SwiftyJSON

class ChangeCityConfigView: ConfigView {
    struct Attributes {
        var title: String
        var hereTitle: String
        var searchResultsTitle: String

        init(json: JSON) {
            self.title = json["title"].stringValue
            self.hereTitle = json["here_title"].stringValue
            self.searchResultsTitle = json["search_results_title"].stringValue
        }
    }
    var attributes: Attributes

    struct Actions {
        var load: String

        init(json: JSON) {
            self.load = json["load"].stringValue
        }
    }
    var actions: Actions

    override init(json: JSON) {
        actions = Actions(json: json["actions"])
        attributes = Attributes(json: json["attributes"])

        super.init(json: json)
    }
}
