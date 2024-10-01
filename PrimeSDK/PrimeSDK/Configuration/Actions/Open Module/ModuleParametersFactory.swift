import Foundation
import SwiftyJSON

class ModuleParametersFactory {
    func make(from json: JSON) throws -> ModuleParameters {
        let moduleName = json["type"].stringValue

        guard
            let moduleType = ModuleType(rawValue: moduleName)
        else {
            throw ModuleTypeError(moduleType: moduleName)
        }

        switch moduleType {
        case .list:
            return ListModuleParameters(json: json)
        case .webpage:
            return WebPageModuleParameters(json: json)
        case .detail:
            return DetailModuleParameters(json: json)
        case .navigatorHome:
            return HomeModuleParameters(json: json)
        }
    }
}
