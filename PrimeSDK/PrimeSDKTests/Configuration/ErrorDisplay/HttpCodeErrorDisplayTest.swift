import Foundation
import PromiseKit
import SwiftyJSON
import Alamofire
import Nimble
import Quick
@testable import PrimeSDK

final class HttpCodeErrorDisplayTests: XCTestCase {
    func testConfigValidateGood() {
        let json = JSON(
            [
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

        let errorDisplay = try? HttpCodeErrorDisplay(json: json, parsingService: ParsingService())
        let dataResponse = DataResponse<JSON>.init(
            request: nil,
            response: HTTPURLResponse(
                url: URL(string: "google.com")!,
                statusCode: 218,
                httpVersion: nil,
                headerFields: nil
            ),
            data: nil,
            result: .success(JSON())
        )

        expect {
            errorDisplay!.validate(response: dataResponse)
        }.to(
            equal("Скачайте новую версию приложения"),
            description: "`validate` is supposed to match error status code and then id `some_id_2`"
        )
    }

    func testConfigValidateBad() {
        let json = JSON(
            [
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

        let errorDisplay = try? HttpCodeErrorDisplay(json: json, parsingService: ParsingService())
        let dataResponse = DataResponse<JSON>.init(
            request: nil,
            response: HTTPURLResponse(
                url: URL(string: "google.com")!,
                statusCode: 217,
                httpVersion: nil,
                headerFields: nil
            ),
            data: nil,
            result: .success(JSON())
        )

        expect {
            errorDisplay!.validate(response: dataResponse)
        }.to(
            beNil(),
            description: "`validate` is supposed not to match erronous status code"
        )
    }

    func testFieldValidateGood() {
        let json = JSON(
            [
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
                    "type": "field",
                    "parameters": [
                        "path": "{{data.status}}"
                    ]
                ]
            ]
        )

        let errorDisplay = try? HttpCodeErrorDisplay(json: json, parsingService: ParsingService())
        let dataResponse = DataResponse<JSON>.init(
            request: nil,
            response: HTTPURLResponse(
                url: URL(string: "google.com")!,
                statusCode: 218,
                httpVersion: nil,
                headerFields: nil
            ),
            data: nil,
            result: .success(
                JSON(
                    [
                        "status": "ok"
                    ]
                )
            )
        )

        expect {
            errorDisplay!.validate(response: dataResponse)
        }.to(
            equal("ok"),
            description: "`validate` is supposed to match erronous status code and get error text from field `status`"
        )
    }
}
