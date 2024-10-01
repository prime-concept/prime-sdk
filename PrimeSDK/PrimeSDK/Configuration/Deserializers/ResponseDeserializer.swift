import Foundation
import PromiseKit
import SwiftyJSON

class ResponseDeserializer {
    var type: String
    var name: String

    var parsingService: ParsingService
    var action: String?
    var viewModel: ViewModelProtocol?

    init(
        json: JSON,
        parsingService: ParsingService,
        action: String? = nil,
        viewModel: ViewModelProtocol? = nil
    ) throws {
        self.type = try json.extract(field: "type").stringValue
        self.name = try json.extract(field: "name").stringValue
        self.parsingService = parsingService
        self.action = action
        self.viewModel = viewModel
    }

    func inject(action: String?, viewModel: ViewModelProtocol?) {
        self.action = action
        self.viewModel = viewModel
    }

    func deserialize(json: JSON) -> Promise<DeserializedViewMap> {
        return Promise { seal in
            seal.fulfill(DeserializedViewMap.empty)
        }
    }

    func connect(deserializers: [String: ResponseDeserializer]) {}
}
