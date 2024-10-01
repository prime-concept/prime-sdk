import UIKit

class DetailTableView: UITableView {
    var headerView: UIView?

    // Cause headerView is under transparent tableView we should pass hit
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let headerView = headerView else {
            return super.hitTest(point, with: event)
        }

        let convertedPoint = self.convert(point, to: headerView)
        if headerView.bounds.contains(convertedPoint) {
            for subview in headerView.subviews.reversed() {
                // Skip subview-receiver if it has isUserInteractionEnabled == false
                // to pass some hits to tableview (e.g. swipes in header area)
                let shouldSubviewInteract = subview.isUserInteractionEnabled
                if subview.frame.contains(convertedPoint) && shouldSubviewInteract {
                    return subview.hitTest(convertedPoint, with: event) ?? subview
                }
            }
        }

        return super.hitTest(point, with: event)
    }
}
