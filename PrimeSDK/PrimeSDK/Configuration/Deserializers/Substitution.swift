import Foundation
import SwiftyJSON

struct Substitution {
    let name: String

    let source: String
    let target: String

    let sourceField: String
    let targetField: String
    let extractField: String

    init(json: JSON) throws {
        name = try json.extract(field: "name").stringValue
        source = try json.extract(field: "source").stringValue
        target = try json.extract(field: "target").stringValue

        let fields = try json.extract(field: "fields")
        sourceField = try fields.extract(field: "source").stringValue
        targetField = try fields.extract(field: "target").stringValue
        extractField = try fields.extract(field: "extract").stringValue
    }
}
