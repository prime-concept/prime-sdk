import Foundation

struct ActionExpressionProcessor: Equatable {
    private let fieldName: String

    init(fieldName: String) {
        self.fieldName = fieldName
    }

    func process(storageName: String) -> Any? {
        guard
            let value = DataStorage.shared.getValue(for: fieldName, in: storageName)
        else {
            return nil
//            fatalError("No value")
        }

        return value
    }
}
