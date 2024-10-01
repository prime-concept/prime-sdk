import Foundation

class BackendGeneratedError: PrimeSDKError {
    private let text: String
    init(text: String) {
        self.text = text
    }

    override var localizedDescription: String {
        return text
    }
}
