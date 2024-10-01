import XCTest
import PromiseKit
import SwiftyJSON
import Nimble
import Quick
@testable import PrimeSDK

final class ConfigViewFactoryTests: XCTestCase {
    func testList() {
        let json = JSON(
            [
                "type": "list",
                "subviews": []
            ]
        )
        let configViewFactory = ConfigViewFactory()
        expect {
            try configViewFactory.make(from: json).view
        }.to(
            beAKindOf(ListConfigView.self),
            description: "Factory should make ListConfigView"
        )
    }

    func testSectionCard() {
        let json = JSON(
            [
                "type": "section-card",
                "subviews": []
            ]
        )
        let configViewFactory = ConfigViewFactory()
        expect {
            try configViewFactory.make(from: json).view
        }.to(
                beAKindOf(ListItemConfigView.self),
                description: "Factory should make ListConfigView"
        )
    }

    func testViewTypeError() {
        let json = JSON(
            [
                "type": "aaaaaaaaaaaaaaaaaaaaaa",
                "subviews": []
            ]
        )
        let configViewFactory = ConfigViewFactory()
        expect {
            try configViewFactory.make(from: json).view
        }.to(
            throwError(errorType: ViewTypeError.self),
            description: "Factory should throw type error"
        )
    }
}
