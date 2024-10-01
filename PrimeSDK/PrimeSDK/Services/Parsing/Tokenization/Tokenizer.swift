import Foundation

final class Tokenizer {
    func tokenize(string: String) -> TokenizedString {
        var results = [Token]()
        var previousIndex = string.startIndex

        func addIfPlain(between startIndex: String.Index, endIndex: String.Index) {
            if startIndex != endIndex {
                results.append(.plainString(string[startIndex..<endIndex]))
            }
        }

        while let expressionStartRange = string[previousIndex...].range(of: "{{") {
            guard let expressionEndRange = string[expressionStartRange.upperBound...].range(of: "}}") else {
                break // expression is not closed
            }

            addIfPlain(between: previousIndex, endIndex: expressionStartRange.lowerBound)

            results.append(
                parseExpression(string[expressionStartRange.upperBound..<expressionEndRange.lowerBound])
            )

            previousIndex = expressionEndRange.upperBound
        }

        addIfPlain(between: previousIndex, endIndex: string.endIndex)

        return TokenizedString(tokens: results)
    }

    private func parseExpression(_ string: String.SubSequence) -> Token {
        let tokens = string.components(separatedBy: ".")

        guard
            let reservedTokenString = tokens.first,
            let reservedToken = ReservedToken(rawValue: reservedTokenString)
        else {
            fatalError("Reserved token not found")
        }

        switch reservedToken {
        case .action:
            guard tokens.count == 2, let nameToken = tokens.last else {
                fatalError("Expected only 2 tokens")
            }

            return .action(
                ActionExpressionProcessor(
                    fieldName: nameToken
                )
            )
        case .shared:
            guard tokens.count == 2, let nameToken = tokens.last else {
                fatalError("Expected only 2 tokens")
            }

            return .shared(
                SharedExpressionProcessor(
                    storageName: "shared",
                    fieldName: nameToken
                )
            )
        case .sender:
            guard tokens.count == 2, let nameToken = tokens.last else {
                fatalError("Expected only 2 tokens")
            }

            return .sender(
                SenderExpressionProcessor(name: nameToken)
            )
        case .data:
            if let substitutionIndex = tokens.firstIndex(of: "substitution") {
                guard
                    let index = Int(tokens[substitutionIndex - 1])
                else {
                    fatalError("Expected iterator")
                }

                return .substitution(
                    SubstitutionExpressionProcessor(
                        name: tokens[substitutionIndex + 1],
                        index: index
                    )
                )
            }

            return .data(
                DataExpressionProcessor(
                    tokens: Array(tokens.dropFirst())
                )
            )
        }
    }
}
