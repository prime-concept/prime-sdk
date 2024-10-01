import Foundation
import PassKit
import SwiftyJSON

class KinohodApplePayItem {
    enum ItemError: Error {
        case parsingError
    }

    class ApplePayMovieItem {
        var name: String
        var price: Decimal

        init?(json: JSON) {
            self.name = json["name"].stringValue
            guard let price = Decimal(string: json["price"].stringValue) else {
                return nil
            }
            self.price = price
        }
    }

    var email: String
    var merchantName: String
    var countryCode: String
    var currencyCode: String
    var items: [ApplePayMovieItem] = []
    var merchantCapability: PKMerchantCapability
    var paymentSystems: [PKPaymentNetwork] = []
    var merchantID: String
    var totalPrice: Decimal
    var companyName: String

    init?(json: JSON) {
        self.email = json["email"].stringValue
        self.merchantName = json["merchantName"].stringValue
        self.countryCode = json["countryCode"].stringValue
        self.currencyCode = json["currencyCode"].stringValue
        self.items = json["items"].arrayValue.compactMap { ApplePayMovieItem(json: $0) }
        self.paymentSystems = json["paymentSystems"].arrayValue.compactMap { PKPaymentNetwork($0.stringValue) }
        self.merchantID = json["merchantId"].stringValue
        self.companyName = json["companyName"].stringValue

        guard let price = Decimal(string: json["totalPrice"].stringValue) else {
            return nil
        }
        self.totalPrice = price

        let merchantCapabilities = json["merchantCapability"].arrayValue.compactMap { $0.int }
        merchantCapability = PKMerchantCapability()
        for cap in merchantCapabilities {
            switch cap {
            case 0:
                merchantCapability.insert(.capabilityEMV)
            case 1:
                merchantCapability.insert(.capability3DS)
            case 2:
                merchantCapability.insert(.capabilityCredit)
            case 3:
                merchantCapability.insert(.capabilityDebit)
            default:
                break
            }
        }
    }
}

extension PKPaymentRequest {
    convenience init?(kinohodApplePayItem: KinohodApplePayItem) {
        self.init()
        supportedNetworks = kinohodApplePayItem.paymentSystems
        merchantCapabilities = kinohodApplePayItem.merchantCapability
        if !PKPaymentAuthorizationViewController.canMakePayments() {
            //TODO: ApplePay not supported
            return nil
        }
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks) {
            //TODO: ApplePay can't be used
            return nil
        }
        merchantIdentifier = "merchant.\(kinohodApplePayItem.merchantID)"
        currencyCode = kinohodApplePayItem.currencyCode
        countryCode = kinohodApplePayItem.countryCode
        paymentSummaryItems = [
            PKPaymentSummaryItem(
                label: kinohodApplePayItem.companyName,
                amount: NSDecimalNumber(decimal: kinohodApplePayItem.totalPrice)
            )
        ]
    }
}
