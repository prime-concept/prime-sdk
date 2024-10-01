import Alamofire
import Foundation
import SwiftyJSON

/**
Kind of `ErrorDisplay` that detects errors based on
existance of fields in JSON recieved from backend
 */
final class ContainsFieldErrorDisplay: ErrorDisplay {
    let messageExtraction: ErrorDisplayMessageExtraction
    let triggerValues: [String]
    let parsingService: ParsingService

    func validate(response: DataResponse<JSON>) throws -> String? {
        for triggerValue in triggerValues {
            if case .success(let json) = response.result {
//                let triggerJson: JSON = try parsingService.processSingleExpression(string: triggerValue, dataJSON: json)
                switch messageExtraction {
                case .config(let map):
                    guard
                        let path = map[triggerValue]
                    else {
                        throw ErrorDisplayIsInconsistent()
                    }
                    return parsingService.process(string: path, json: json)
                case .field(let path):
                    return parsingService.process(string: path, json: json)
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
            .map { try $0.string.unwrap(field: "trigger_values") }
    }
}
