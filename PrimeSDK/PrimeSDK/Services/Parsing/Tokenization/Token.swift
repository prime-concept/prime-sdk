import Foundation

enum Token: Equatable {
    case plainString(String.SubSequence)
    case substitution(SubstitutionExpressionProcessor)
    case data(DataExpressionProcessor)
    case sender(SenderExpressionProcessor)
    case action(ActionExpressionProcessor)
    case shared(SharedExpressionProcessor)

    static func == (lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.plainString(let lval), .plainString(let rval)):
            return lval == rval
        case (.action(let lval), .action(let rval)):
            return lval == rval
        case (.data(let lval), .data(let rval)):
            return lval == rval
        case (.sender(let lval), .sender(let rval)):
            return lval == rval
        case (.shared(let lval), .shared(let rval)):
            return lval == rval
        default:
            return false
        }
    }
}
