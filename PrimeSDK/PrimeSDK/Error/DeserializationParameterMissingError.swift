import Foundation

class DeserializationAttributeMissingError: PrimeSDKError {
    private var attributeName: String

    init(attributeName: String) {
        self.attributeName = attributeName
    }

    override var localizedDescription: String {
        return "Missing attribute \(attributeName)"
    }
}
