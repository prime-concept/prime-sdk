import UIKit

/// Protocol for opening URL's in `UIApplication`
public protocol URLAppOpenable {
    func applicationOpenURL(url: URL)
}

public extension URLAppOpenable {
    func applicationOpenURL(url: URL) {
        guard UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
