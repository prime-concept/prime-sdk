import Foundation
import SwiftyJSON

/**
 Creates objects of type `ErrorDisplay` based on type of trigger
 */
final class ErrorDisplayFactory {
    enum Trigger: String {
        case httpCode = "http_code_is"
        case containsField = "contains_field"
    }

    enum FieldNames {
        static let triggerType = "trigger_type"
        static let messageExtraction = "message_extraction"
    }

    func make(from json: JSON, parsingService: ParsingService) throws -> ErrorDisplay {
        let trigger = try json
            .extract(field: FieldNames.triggerType)
            .string
            .flatMap(Trigger.init)
            .unwrap(field: FieldNames.triggerType)

        switch trigger {
        case .httpCode:
            return try HttpCodeErrorDisplay(json: json, parsingService: parsingService)
        case .containsField:
            return try ContainsFieldErrorDisplay(json: json, parsingService: parsingService)
        }
    }
}
