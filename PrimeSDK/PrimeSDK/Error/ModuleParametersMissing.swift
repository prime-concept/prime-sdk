import Foundation

public class ModuleParametersMissingError: PrimeSDKError {
    override public var localizedDescription: String {
        return "Open module parameters should be set in \"module_parameters\""
    }
}
