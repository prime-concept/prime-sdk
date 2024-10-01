import Foundation
import SwiftyJSON

class OpenModuleConfigAction: ConfigAction {
    let moduleParametersFactory = ModuleParametersFactory()

    enum TransitionType {
        case push
        case modal
        case card

        init(name: String) {
            switch name {
            case "push":
                self = .push
            case "modal":
                self = .modal
            case "card":
                self = .card
            default:
                self = .modal
            }
        }
    }
    var transitionType: TransitionType

    var moduleParameters: ModuleParameters

    override init(json: JSON) throws {
        let moduleParametersJson = json["module_parameters"]
        guard
            moduleParametersJson.dictionary != nil
        else {
            throw ModuleParametersMissingError()
        }

        moduleParameters = try moduleParametersFactory.make(from: moduleParametersJson)

        let transitionParametersJSON = json["transition_parameters"]
        transitionType = TransitionType(name: transitionParametersJSON["transition_type"].stringValue)

        try super.init(json: json)
    }
}
