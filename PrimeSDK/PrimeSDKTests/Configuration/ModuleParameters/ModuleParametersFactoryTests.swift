import Foundation
import PromiseKit
import SwiftyJSON
import Nimble
import Quick
@testable import PrimeSDK

final class ModuleParametersFactoryTests: XCTestCase {
    func testList() {
        let json = JSON(
            [
                "type": "list"
            ]
        )
        let moduleParametersFactory = ModuleParametersFactory()
        expect {
            try moduleParametersFactory.make(from: json)
        }.to(
            beAKindOf(ListModuleParameters.self),
            description: "Factory should make ListModuleParameters"
        )
    }

    func testWebpage() {
        let json = JSON(
            [
                "type": "webpage"
            ]
        )
        let moduleParametersFactory = ModuleParametersFactory()
        expect {
            try moduleParametersFactory.make(from: json)
        }.to(
            beAKindOf(WebPageModuleParameters.self),
            description: "Factory should make WebPageModuleParameters"
        )
    }

    func testTypeError() {
        let json = JSON(
            [
                "type": "aaaaaaaaaaaaa"
            ]
        )
        let moduleParametersFactory = ModuleParametersFactory()
        expect {
            try moduleParametersFactory.make(from: json)
        }.to(
            throwError(errorType: ModuleTypeError.self),
            description: "Factory should throw type error"
        )
    }
}
