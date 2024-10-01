import Foundation
import SwiftyJSON

final class ResponseDeserializerFactory {
    func make(from json: JSON, parsingService: ParsingService) throws -> ResponseDeserializer {
        let type = json["type"].stringValue

        guard
            let deserializerType = DeserializerType(rawValue: type)
        else {
            throw DeserializerTypeError(deserializerType: type)
        }

        switch deserializerType {
        case .object:
            return try ObjectDeserializer(json: json, parsingService: parsingService)
        }
    }
}
