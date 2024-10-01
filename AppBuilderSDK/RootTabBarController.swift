import PrimeSDK
import UIKit

class RootTabBarController: UITabBarController {
    convenience init(configurationService: ConfigurationLoadingService) {
        self.init(nibName: nil, bundle: nil)
        self.viewControllers = [
            ("App", ViewController(configurationService: configurationService), UIImage(named: "tab-lego")),
            ("URL", URLConfigurationViewController(), UIImage(named: "tab-api")),
            ("Shared storage", SharedStorageConfigurationViewController(), UIImage(named: "tab-storage"))
        ].map(createTab)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(configurationUpdated),
            name: .configuartionUpdate,
            object: nil
        )
    }

    func createTab(title: String, viewController: UIViewController, image: UIImage?) -> UIViewController {
        let navigationViewController = UINavigationController(rootViewController: viewController)
        navigationViewController.tabBarItem = UITabBarItem(title: title, image: image, tag: 0)
        return navigationViewController
    }

    @objc
    func configurationUpdated(_ notification: Notification) {
        guard let configuration = notification.userInfo?["config"] as? ConfigurationLoadingService,
            let viewControllers = viewControllers
        else {
            return
        }
        let updatedViewControllers = [
            createTab(
                title: "App",
                viewController: ViewController(configurationService: configuration),
                image: UIImage(named: "tab-lego")
            )
        ] + viewControllers.dropFirst()
        setViewControllers(updatedViewControllers, animated: true)
        selectedIndex = 0
    }
}
