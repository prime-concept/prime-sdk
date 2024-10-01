import Foundation
import SwiftyJSON

enum SharingParametersType: String {
    case branchОbject = "branch_object"
    case url
}

class SharingParametersFactory {
    func make(from json: JSON) throws -> SharingParameters {
        let name = json["type"].stringValue

        guard
            let type = SharingParametersType(rawValue: name)
        else {
            throw ModuleTypeError(moduleType: name)
        }

        switch type {
        case .branchОbject:
            return BranchSharingParameters(json: json)
        case .url:
            return UrlSharingParameters(json: json)
        }
    }
}
