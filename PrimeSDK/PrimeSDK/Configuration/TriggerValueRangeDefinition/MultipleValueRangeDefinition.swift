import Foundation
import SwiftyJSON

/**
 A kind of `TriggerValueRangeDefinition` that depicts a range of values
 */
struct MultipleValueRangeDefinition: TriggerValueRangeDefinition {
    let id: String
    private let start: Int
    private let end: Int

    init(parametersJSON json: JSON) throws {
        id = try json.extract(field: "id").stringValue
        start = try json.extract(field: "start").intValue
        end = try json.extract(field: "end").intValue
    }

    func contains(value: Int) -> Bool {
        return (start...end).contains(value)
    }
}
