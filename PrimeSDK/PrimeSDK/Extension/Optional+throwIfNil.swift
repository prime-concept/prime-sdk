import Foundation

extension Optional {
    func unwrap(field: String) throws -> Wrapped {
        switch self {
        case .none:
            throw WrongFieldError(fieldName: field)
        case .some(let value):
            return value
        }
    }
}
