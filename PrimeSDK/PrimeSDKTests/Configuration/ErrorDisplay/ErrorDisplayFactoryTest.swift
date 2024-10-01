import Foundation
import PromiseKit
import SwiftyJSON
import Alamofire
import Nimble
import Quick
@testable import PrimeSDK

final class ErrorDisplayFactoryTests: XCTestCase {
    func testHttpCode() {
        let json = JSON(
            [
                "trigger_type": "http_code_is",
                "trigger_values": [
                    [

                        "type": "single_value",
                        "parameters": [
                            "id": "some_id_2",
                            "value": 218
                        ]
                    ]
                ],
                "message_extraction": [
                    "type": "config",
                    "parameters": [
                        "map": [
                            "some_id": "Приложению плохо, попробуйте позже",
                            "some_id_2": "Скачайте новую версию приложения"
                        ]
                    ]
                ]
            ]
        )

        let errorDisplayFactory = ErrorDisplayFactory()

        expect {
            try errorDisplayFactory.make(from: json, parsingService: ParsingService())
        }.to(
            beAKindOf(HttpCodeErrorDisplay.self),
            description: "This json is supposed to produce error display of type http_code_is"
        )
    }
}
