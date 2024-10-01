import Foundation
import PromiseKit
import SwiftyJSON
import Nimble
import Quick
@testable import PrimeSDK

final class ConfigActionFactoryTests: XCTestCase {
    func testLoadList() {
        let json = JSON(
            [
                "type": "load"
            ]
        )
        let configActionFactory = ConfigActionFactory()
        expect {
            try configActionFactory.make(from: json).action
        }.to(
            beAKindOf(LoadConfigAction.self),
            description: "Factory should make ListConfigView"
        )
    }

    func testOpenModuleWithParameters() {
        let json = JSON(
            [
                "type": "open-module",
                "module_parameters": [
                    "type": "list",
                    "name": "events-list"
                ]
            ]
        )
        let configActionFactory = ConfigActionFactory()
        expect {
            try configActionFactory.make(from: json).action
        }.to(
            beAKindOf(OpenModuleConfigAction.self),
            description: "Factory should make ListConfigView"
        )
    }

    func testOpenModuleWithoutParameters() {
        let json = JSON(
            [
                "type": "open-module"
            ]
        )
        let configActionFactory = ConfigActionFactory()
        expect {
            try configActionFactory.make(from: json).action
        }.to(
            throwError(errorType: ModuleParametersMissingError.self),
            description: "Factory should make ListConfigView"
        )
    }

    func testActionTypeError() {
        let json = JSON(
            [
                "type": "aaaaaaaaaaaaaaaaaaaaaa"
            ]
        )
        let configActionFactory = ConfigActionFactory()
        expect {
            try configActionFactory.make(from: json).action
        }.to(
            throwError(errorType: ActionTypeError.self),
            description: "Factory should throw type error"
        )
    }
}
