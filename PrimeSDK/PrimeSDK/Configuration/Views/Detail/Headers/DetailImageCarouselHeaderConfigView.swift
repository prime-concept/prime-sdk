import Foundation
import SwiftyJSON

class DetailImageCarouselHeaderConfigView: ConfigView {
    struct Attributes {
        var title: String?
        var subtitle: String?
        var startDate: Date?
        var endDate: Date?
        var showOndaLogo = false
        var shouldUpdateStatus = false

        init(json: JSON) {
            self.title = json["title"].string
            self.subtitle = json["subtitle"].string
            if let dateString = json["start_date"].string {
                self.startDate = Date(string: dateString)
            }

            if let dateString = json["end_date"].string {
                self.endDate = Date(string: dateString)
            }

            if let showOndaLogo = json["show_onda_logo"].bool {
                self.showOndaLogo = showOndaLogo
            }

            shouldUpdateStatus = json["should_update_status"].boolValue
        }
    }
    var attributes: Attributes

    override init(json: JSON) {
        attributes = Attributes(json: json["attributes"])
        super.init(json: json)
    }
}
