import Foundation
import SwiftyJSON

class ConfigActionFactory {
    func make(from json: JSON) throws -> (name: String, action: ConfigAction) {
        let name = json["name"].stringValue
        let type = json["type"].stringValue

        guard
            let actionType = ActionType(rawValue: type)
        else {
            throw ActionTypeError(actionType: type)
        }

        switch actionType {
        case .load:
            return (name: name, action: try LoadConfigAction(json: json))
        case .openModule:
            return (name: name, action: try OpenModuleConfigAction(json: json))
        case .share:
            return (name: name, action: try ShareConfigAction(json: json))
        }
    }
}
