import Foundation
import PromiseKit
import SwiftyJSON

class ResponseDeserializerMap {
    var fieldForAttributeId: [String: String] = [:]
    var substitutions = [Substitution]()

    init(json: JSON) throws {
        self.fieldForAttributeId = json["objects"].dictionaryObject as? [String: String] ?? [:]
        self.substitutions = try json["substitutions"].arrayValue.map { try Substitution(json: $0) }
    }
}

class ObjectDeserializer: ResponseDeserializer {
    var map: ResponseDeserializerMap

    override init(
        json: JSON,
        parsingService: ParsingService,
        action: String? = nil,
        viewModel: ViewModelProtocol? = nil
    ) throws {
        self.map = try ResponseDeserializerMap(json: json["map"])
        try super.init(json: json, parsingService: parsingService, action: action, viewModel: viewModel)
    }

    override func deserialize(json: JSON) -> Promise<DeserializedViewMap> {
        return Promise { seal in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else {
                    seal.reject(NSError())
                    return
                }
                let deserializedViewMap = try? DeserializedViewMap(
                    json: json,
                    deserializerMap: self.map,
                    action: self.action,
                    viewModel: self.viewModel,
                    parsingService: self.parsingService
                )
                if let deserializedViewMap = deserializedViewMap {
                    seal.fulfill(deserializedViewMap)
                } else {
                    seal.reject(NSError())
                }
            }
        }
    }
}
