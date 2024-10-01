import Foundation
import SwiftyJSON

public class Configuration {
    //TODO: Extract dependency
    var configViewFactory = ConfigViewFactory()
    var configActionFactory = ConfigActionFactory()

    var views: [String: ConfigView] = [:]
    var actions: [String: ConfigAction] = [:]
    init(json: JSON) {
        for viewJson in json["views"].arrayValue {
            if let namedView = try? configViewFactory.make(from: viewJson) {
                views[namedView.name] = namedView.view
            }
        }

        for actionJson in json["actions"].arrayValue {
            if let namedAction = try? configActionFactory.make(from: actionJson) {
                actions[namedAction.name] = namedAction.action
            }
        }
    }
}
