import Foundation
import PassKit
import SwiftyJSON

class KinohodApplePayToken {
    class PaymentMethod {
        var displayName: String
        var network: String
        var type: UInt

        init(paymentMethod: PKPaymentMethod) {
            self.displayName = paymentMethod.displayName ?? ""
            self.network = paymentMethod.network?.rawValue ?? ""
            self.type = paymentMethod.type.rawValue
        }

        var dictionary: [String: Any] {
            return [
                "displayName": self.displayName,
                "network": self.network,
                "type": self.type
            ]
        }
    }

    var paymentMethod: PaymentMethod
    var transactionIdentifier: String
    var paymentData: String
    var paymentNetwork: String

    init(paymentToken: PKPaymentToken) {
        self.paymentMethod = PaymentMethod(paymentMethod: paymentToken.paymentMethod)
        self.transactionIdentifier = paymentToken.transactionIdentifier
        self.paymentData = paymentToken.paymentData.base64EncodedString()
        self.paymentNetwork = paymentToken.paymentNetwork
    }

    var dictionary: [String: Any] {
        return [
            "paymentMethod": self.paymentMethod.dictionary,
            "transactionIdentifier": self.transactionIdentifier,
            "paymentData": self.paymentData,
            "paymentNetwork": self.paymentNetwork
        ]
    }
}
