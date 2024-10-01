import Foundation

class ConfigurationFileError: PrimeSDKError {
    override var localizedDescription: String {
        return "Couldn't read configuration file."
    }
}
