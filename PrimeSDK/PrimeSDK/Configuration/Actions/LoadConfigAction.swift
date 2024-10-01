import Foundation
import SwiftyJSON

class LoadConfigAction: ConfigAction {
    var request: ConfigRequest
    var response: ConfigResponse

    override init(json: JSON) throws {
        self.request = ConfigRequest(json: json["request"], parsingService: ParsingService())
        self.response = try ConfigResponse(json: json["response"], parsingService: ParsingService())

        try super.init(json: json)
    }
}
