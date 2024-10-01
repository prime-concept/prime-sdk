import FloatingPanel
import Foundation

class KinohodTicketsBookerPanelLayout: FloatingPanelLayout {
    private var initialBottomInset: CGFloat = 216.0

    init(initialBottomInset: CGFloat) {
        self.initialBottomInset = initialBottomInset
    }

    var initialPosition: FloatingPanelPosition {
        return .half
    }

    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full:
            return 16.0 // A top inset from safe area
        case .half:
            return initialBottomInset // A bottom inset from the safe area
        default:
            return nil // Or `case .hidden: return nil`
        }
    }

    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .half]
    }
}
