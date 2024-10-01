import Foundation

public class ActionTypeError: PrimeSDKError {
    private var actionType: String

    init(actionType: String) {
        self.actionType = actionType
    }

    override public var localizedDescription: String {
        if actionType.isEmpty {
            return "Action type is empty or isn't declared"
        } else {
            return "Unknown action type \"\(actionType)\". Please check the documentation."
        }
    }
}
