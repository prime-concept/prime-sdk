import XCTest
import PromiseKit
import SwiftyJSON
import Nimble
import Quick
@testable import PrimeSDK

final class TokenizerTests: XCTestCase {
    func testTokenizationExpressionBetweenPlainStrings() {
        let string = "bobloh{{data.title}} "

        expect {
            Tokenizer().tokenize(string: string)
        }.to(
            equal(
                TokenizedString(
                    tokens: [
                        .plainString("bobloh"[...]),
                        .data(DataExpressionProcessor(tokens: ["title"])),
                        .plainString(" ")
                    ]
                )
            ),
            description: "Expected correct tokens"
        )
    }

    func testTokenizationExpressionOnly() {
        let string = "{{sender.title}}"
        expect {
            Tokenizer().tokenize(string: string)
        }.to(
            equal(
                TokenizedString(
                    tokens: [
                        .sender(SenderExpressionProcessor(name: "title"))
                    ]
                )
            ),
            description: "Expected correct tokens"
        )
    }

    func testTokenizationPlainStringOnly() {
        let string = "sdfadkfj sakdjf"

        expect {
            Tokenizer().tokenize(string: string)
        }.to(
            equal(
                TokenizedString(
                    tokens: [
                        .plainString("sdfadkfj sakdjf")
                    ]
                )
            ),
            description: ""
        )
    }

    func testTokenizationUnclosedExpression() {
        expect {
            Tokenizer().tokenize(string: "sdfadkfj{{ sakdjf")
        }.to(
            equal(
                TokenizedString(
                    tokens: [
                        .plainString("sdfadkfj{{ sakdjf")
                    ]
                )
            ),
            description: "Expected correct tokens"
        )
    }

    func testTokenizationTechnolabURL() {
        let string = "https://api.kinohod.ru/p/{{sender.cell_width}}x{{sender.cell_height}}/{{data.data.0.attributes.posterLandscape.crop}}"
        expect {
            Tokenizer().tokenize(string: string)
        }.to(
            equal(
                TokenizedString(
                    tokens: [
                        .plainString("https://api.kinohod.ru/p/"),
                        .sender(SenderExpressionProcessor(name: "cell_width")),
                        .plainString("x"),
                        .sender(SenderExpressionProcessor(name: "cell_height")),
                        .plainString("/"),
                        .data(DataExpressionProcessor(tokens: ["data", "0", "attributes", "posterLandscape", "crop"]))
                    ]
                )
            ),
            description: "Expected correct tokens"
        )
    }
}
