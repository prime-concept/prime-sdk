import Branch
import PrimeSDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let sdkManager = PrimeSDKManager()
        DataStorage.shared.set(value: "fd31f6e0-ddd7-44c4-bac2-3095a47ff1eb", for: "x-app-token")

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
        window.rootViewController = RootTabBarController(
            configurationService: LocalConfigurationLoadingService(fileName: "AppConfigurationArmenia")
        )
        self.window = window

        Branch.getInstance().initSession(launchOptions: launchOptions) { params, _ in
            guard let data = params as? [String: AnyObject] else {
                return
            }

            DispatchQueue.main.async {
                if let module = sdkManager.getDeeplinkModule(
                    branchData: data,
                    configurationLoadingService: LocalConfigurationLoadingService(fileName: "AppConfigurationArmenia")
                ) {
                    window.rootViewController?.show(module, sender: nil)
                }
            }
        }

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        //swiftlint:disable:next colon
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        // swiftlint:disable:next discouraged_optional_collection
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        // handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }
}
