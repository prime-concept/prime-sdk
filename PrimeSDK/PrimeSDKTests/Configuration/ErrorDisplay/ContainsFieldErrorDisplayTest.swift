import Foundation
import PromiseKit
import SwiftyJSON
import Alamofire
import Nimble
import Quick
@testable import PrimeSDK

final class ContainsFieldErrorDisplayTests: XCTestCase {
    func testFieldValidateGood() {
        let json = JSON(
            [
                "trigger_values": [
                    "{{data.error}}"
                ],
                "message_extraction": [
                    "type": "field",
                    "parameters": [
                        "path": "{{data.error_description}}"
                    ]
                ]
            ]
        )

        let errorDisplay = try? ContainsFieldErrorDisplay(json: json, parsingService: ParsingService())
        let dataResponse = DataResponse<JSON>.init(
            request: nil,
            response: HTTPURLResponse(
                url: URL(string: "google.com")!,
                statusCode: 0,
                httpVersion: nil,
                headerFields: nil
            ),
            data: nil,
            result: .success(
                JSON(
                    [
                        "error": "some error",
                        "error_description": "ok"
                    ]
                )
            )
        )

        expect {
            try errorDisplay!.validate(response: dataResponse)
        }.to(
            equal("ok"),
            description: "`validate` is supposed to find an erronous field and the error description"
        )
    }

    func testConfigValidateGood() {
        let json = JSON(
            [
                "trigger_values": [
                    "{{data.error}}"
                ],
                "message_extraction": [
                    "type": "config",
                    "parameters": [
                        "map": [
                            "{{data.error}}": "{{data.error_description}}"
                        ]
                    ]
                ]
            ]
        )

        let errorDisplay = try? ContainsFieldErrorDisplay(json: json, parsingService: ParsingService())
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
                        "error": "some error",
                        "error_description": "ok"
                    ]
                )
            )
        )

        expect {
            try errorDisplay!.validate(response: dataResponse)
        }.to(
            equal("ok"),
            description: "`validate` is supposed to find an erronous field and the error description"
        )
    }

    func testConfigValidateInconsistentError() {
        let json = JSON(
            [
                "trigger_values": [
                    "{{data.error}}"
                ],
                "message_extraction": [
                    "type": "config",
                    "parameters": [
                        "map": [
                            "{{data.aaaaaaaaaaaaa}}": "{{data.error_description}}"
                        ]
                    ]
                ]
            ]
        )

        let errorDisplay = try? ContainsFieldErrorDisplay(json: json, parsingService: ParsingService())
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
                        "error": "some error",
                        "error_description": "ok"
                    ]
                )
            )
        )

        expect {
            try errorDisplay!.validate(response: dataResponse)
        }.to(
            throwError(errorType: ErrorDisplayIsInconsistent.self),
            description: "`validate` is supposed not to find a matching path in map"
        )
    }
}
