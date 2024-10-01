import Foundation
import SwiftyJSON

enum KinohodApplePayResponse {
    class ResponseError: Error {
        var code: Int?
        var errorDescription: String?
        var orderStatus: String?
        var actionCode: String?
        var actionCodeDescription: String?

        init(json: JSON) {
            self.code = json["code"].int
            self.errorDescription = json["description"].string
            self.orderStatus = json["orderStatus"].string
            self.actionCode = json["actionCode"].string
            self.actionCodeDescription = json["actionCodeDescription"].string
        }
    }

    case success(orderID: String)
    case error(error: ResponseError)

    init(json: JSON) {
        if let orderID = json["orderId"].string {
            self = .success(orderID: orderID)
            return
        } else {
            self = .error(error: ResponseError(json: json["error"]))
        }
    }
}
