import SwiftMessages
import UIKit

protocol CustomErrorShowable {
    func showError(text: String)
}

extension UIViewController: CustomErrorShowable {
    func showError(text: String) {
        let messages = SwiftMessages.sharedInstance
        let statusBarHeight = UIApplication.shared.statusBarFrame.height

        messages.hide()

        // TODO: Incapsulate in router layer
        var config = SwiftMessages.Config()
        config.duration = .seconds(seconds: 1)
        config.interactiveHide = false

        let notificationView = TextNotificationView()
        notificationView.text = text
        if view.layoutMargins.top <= statusBarHeight {
            notificationView.layoutMarginAdditions.top = -statusBarHeight / 2
            notificationView.collapseLayoutMarginAdditions = false
        }
        messages.show(config: config, view: notificationView)
    }
}
