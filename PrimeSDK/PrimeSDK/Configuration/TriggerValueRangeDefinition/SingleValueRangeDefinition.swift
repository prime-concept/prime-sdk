import Foundation
import SwiftyJSON

/**
 A kind of `TriggerValueRangeDefinition` that depicts a single value
 */
struct SingleValueRangeDefinition: TriggerValueRangeDefinition {
    let id: String
    private let value: Int

    init(parametersJSON json: JSON) throws {
        id = try json.extract(field: "id").stringValue
        value = try json.extract(field: "value").intValue
    }

    func contains(value: Int) -> Bool {
        return self.value == value
    }
}
