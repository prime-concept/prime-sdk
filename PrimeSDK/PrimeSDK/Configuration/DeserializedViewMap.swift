import Foundation
import SwiftyJSON

//TODO: Mb remove this layer & deserialize into viewmodel
public final class DeserializedViewMap {
    static var empty = DeserializedViewMap()

    var valueForAttributeID: [String: Any] = [:]

    init(
        json: JSON,
        deserializerMap: ResponseDeserializerMap,
        action: String?,
        viewModel: ViewModelProtocol?,
        parsingService: ParsingService
    ) throws {
        for (attributeID, field) in deserializerMap.fieldForAttributeId {
            let indexedRecords = parsingService.expandAllIndexes(key: attributeID, value: field, dataJSON: json)

            for record in indexedRecords {
                if let value = record.value as? String {
                    valueForAttributeID[record.key] = try parsingService.process(
                        string: value,
                        json: json,
                        deserializerMap: deserializerMap,
                        action: action,
                        viewModel: viewModel
                    )
                } else {
                    valueForAttributeID[record.key] = record.value
                }
            }
        }
    }

    private init() {
    }
}
