import Foundation

final class WrongOrMissingFieldError: PrimeSDKError {
    private let fieldName: String

    init(fieldName: String) {
        self.fieldName = fieldName
    }
}
