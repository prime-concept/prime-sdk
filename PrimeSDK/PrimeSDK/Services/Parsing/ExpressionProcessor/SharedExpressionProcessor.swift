import Foundation

struct SharedExpressionProcessor: Equatable {
    private let storageName: String
    private let fieldName: String

    init(storageName: String, fieldName: String) {
        self.storageName = storageName
        self.fieldName = fieldName
    }

    func process() -> Any? {
        return DataStorage.shared.getValue(for: fieldName, in: storageName)
    }
}

enum ExpressionProcessingError: Error {
    case noValue
}
