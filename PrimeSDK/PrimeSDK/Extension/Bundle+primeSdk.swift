import Foundation

extension Bundle {
    public static var primeSdk: Bundle {
        //swiftlint:disable:next force_unwrapping
        return Bundle(identifier: "ru.technolab.PrimeSDK")!
    }

    public var displayName: String {
        // swiftlint:disable:next force_cast
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
}
