import Alamofire
import Foundation
import SwiftyJSON

/**
 Kind of `ErrorDisplay` that detects errors based on HTTP status code
 */
final class HttpCodeErrorDisplay: ErrorDisplay {
    let messageExtraction: ErrorDisplayMessageExtraction
    let triggerValues: [TriggerValueRangeDefinition]
    let parsingService: ParsingService

    func validate(response: DataResponse<JSON>) -> String? {
        guard
            let statusCode = response.response?.statusCode
        else {
            return nil
        }

        for triggerValue in triggerValues {
            if triggerValue.contains(value: statusCode) {
                switch messageExtraction {
                case .config(let map):
                    return map[triggerValue.id]
                case .field(let path):
                    if case .success(let json) = response.result {
                        return parsingService.process(string: path, json: json)
                    }

                    return nil
                }
            }
        }

        return nil
    }

    init(json: JSON, parsingService: ParsingService) throws {
        self.parsingService = parsingService
        messageExtraction = try ErrorDisplayMessageExtraction(json: try json.extract(field: "message_extraction"))
        triggerValues = try json
            .extract(field: "trigger_values")
            .arrayValue
            .map { try TriggerValueRangeDefinitionFactory().make(from: $0) }
    }
}
