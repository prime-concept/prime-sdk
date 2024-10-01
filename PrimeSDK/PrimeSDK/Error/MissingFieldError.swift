import Foundation

final class MissingFieldError: PrimeSDKError {
    private let fieldName: String

    init(fieldName: String) {
        self.fieldName = fieldName
    }
}
