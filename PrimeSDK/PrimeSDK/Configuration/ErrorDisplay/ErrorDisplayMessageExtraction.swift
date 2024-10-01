import Alamofire
import Foundation
import SwiftyJSON

/**
 Responsible for definition of the way to extract the error message
 */
enum ErrorDisplayMessageExtraction {
    case config([String: String])
    case field(String)

    enum FieldNames {
        static let parameters = "parameters"
        static let map = "map"
        static let path = "path"
        static let type = "type"
    }

    init(json: JSON) throws {
        switch try json.extract(field: FieldNames.type).stringValue {
        case "config":
            let mapJson = try json
                .extract(field: FieldNames.parameters)
                .extract(field: FieldNames.map)
                .dictionaryValue
            let map = try mapJson.mapValues { json -> String in
                guard let value = json.string else {
                    throw WrongOrMissingFieldError(fieldName: FieldNames.map)
                }
                return value
            }

            self = .config(map)
        case "field":
            let path = try json
                .extract(field: FieldNames.parameters)
                .extract(field: FieldNames.path)
                .stringValue

            self = .field(path)
        default:
            throw WrongOrMissingFieldError(fieldName: FieldNames.type)
        }
    }
}
