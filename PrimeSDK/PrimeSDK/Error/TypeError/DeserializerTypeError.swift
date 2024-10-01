import Foundation

public class DeserializerTypeError: PrimeSDKError {
    private var deserializerType: String

    init(deserializerType: String) {
        self.deserializerType = deserializerType
    }

    override public var localizedDescription: String {
        if deserializerType.isEmpty {
            return "Deserializer type is empty or isn't declared"
        } else {
            return "Unknown deserializer type \"\(deserializerType)\". Please check the documentation."
        }
    }
}
