import Foundation

public class ModuleTypeError: PrimeSDKError {
    private var moduleType: String

    init(moduleType: String) {
        self.moduleType = moduleType
    }

    override public var localizedDescription: String {
        if moduleType.isEmpty {
            return "Module type is empty or isn't declared"
        } else {
            return "Unknown module type \"\(moduleType)\". Please check the documentation."
        }
    }
}
