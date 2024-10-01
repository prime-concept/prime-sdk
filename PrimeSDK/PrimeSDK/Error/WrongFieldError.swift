import Foundation

final class WrongFieldError: PrimeSDKError {
    private let fieldName: String

    init(fieldName: String) {
        self.fieldName = fieldName
    }
}
