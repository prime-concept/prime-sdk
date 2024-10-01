import Foundation
import SwiftyJSON

public final class ConfigResponse {
    //TODO: Inject this dependency here? Extract to some service?
    private var responseDeserializerFactory = ResponseDeserializerFactory()
    private var errorDisplayFactory = ErrorDisplayFactory()

    var deserializer: ResponseDeserializer? {
        return deserializers[deserializerName]
    }

    private var parsingService: ParsingService
    private var action: String?
    private var viewModel: ViewModelProtocol?

    private var deserializerName: String
    private var deserializers: [String: ResponseDeserializer] = [:]
    var errorDisplay: ErrorDisplay?
    func inject(action: String?, viewModel: ViewModelProtocol? = nil) {
        self.action = action
        self.viewModel = viewModel
        for deserializer in deserializers {
            deserializer.value.inject(action: action, viewModel: viewModel)
        }
    }

    init(
        json: JSON,
        action: String? = nil,
        viewModel: ViewModelProtocol? = nil,
        parsingService: ParsingService
    ) throws {
        deserializerName = json["deserializer"].stringValue

        self.action = action
        self.viewModel = viewModel
        self.parsingService = parsingService

        let deserializersArray = json["deserializers"].arrayValue.compactMap {
            try? self.responseDeserializerFactory.make(from: $0, parsingService: parsingService)
        }

        for deserializer in deserializersArray {
            deserializers[deserializer.name] = deserializer
        }
        for deserializer in deserializersArray {
            deserializer.connect(deserializers: deserializers)
        }

        let errorDisplayJson = json["error_display"]
        if errorDisplayJson.dictionary != nil {
            errorDisplay = try errorDisplayFactory.make(from: errorDisplayJson, parsingService: parsingService)
        }
    }
}
