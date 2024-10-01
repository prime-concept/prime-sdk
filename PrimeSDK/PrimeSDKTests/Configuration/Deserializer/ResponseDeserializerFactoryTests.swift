import Foundation
import PromiseKit
import SwiftyJSON
import Nimble
import Quick
@testable import PrimeSDK

final class ResponseDeserializerFactoryTests: XCTestCase {
    func testObject() {
        let json = JSON(
            [
                "name": "o",
                "type": "object"
            ]
        )
        let responseDeserializerFactory = ResponseDeserializerFactory()
        expect {
            try responseDeserializerFactory.make(from: json, parsingService: ParsingService())
        }.to(
            beAKindOf(ObjectDeserializer.self),
            description: "Factory should make ObjectDeserializer"
        )
    }

    func testDeserializerTypeError() {
        let json = JSON(
            [
                "type": "aaaaaaaaaaaaaaaaaaa"
            ]
        )
        let responseDeserializerFactory = ResponseDeserializerFactory()
        expect {
            try responseDeserializerFactory.make(from: json, parsingService: ParsingService())
        }.to(
            throwError(errorType: DeserializerTypeError.self),
            description: "Factory should throw type error"
        )
    }
}
