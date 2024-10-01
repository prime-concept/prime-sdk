import Foundation
import SwiftyJSON

/**
 Creates objects of type `TriggerValueRangeDefinition` based on type of trigger
 */
final class TriggerValueRangeDefinitionFactory {
    enum TypeNames: String {
        case range = "range"
        case singleValue = "single_value"
    }

    func make(from json: JSON) throws -> TriggerValueRangeDefinition {
        let typeString = try json.extract(field: "type").stringValue
        let type = try TypeNames(rawValue: typeString).unwrap(field: "type")
        let parametersJSON = try json.extract(field: "parameters")

        switch type {
        case .range:
            return try MultipleValueRangeDefinition(parametersJSON: parametersJSON)
        case .singleValue:
            return try SingleValueRangeDefinition(parametersJSON: parametersJSON)
        }
    }
}
