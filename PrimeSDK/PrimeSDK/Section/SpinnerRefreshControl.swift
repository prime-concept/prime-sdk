import UIKit

public final class SpinnerRefreshControl: UIRefreshControl {
    private static let spinnerHeight: CGFloat = 25.0

    private var isInited = false
    private var spinnerView: SpinnerView?

    override public func layoutSubviews() {
        super.layoutSubviews()

        if !isInited {
            isInited = true
            setupSubviews()
        }
    }

    public func updateScrollState() {
        let pullRatio = min(
            1.0,
            bounds.height / SpinnerRefreshControl.spinnerHeight
        )

        spinnerView?.alpha = pullRatio
    }

    private func setupSubviews() {
        backgroundColor = .clear
        tintColor = .clear
        subviews.first?.alpha = 0

        let spinnerView = SpinnerView()
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinnerView)
        spinnerView.centerXAnchor.constraint(
            equalTo: centerXAnchor
        ).isActive = true
        spinnerView.centerYAnchor.constraint(
            equalTo: centerYAnchor
        ).isActive = true
        spinnerView.widthAnchor.constraint(
            equalToConstant: SpinnerRefreshControl.spinnerHeight
        ).isActive = true
        spinnerView.heightAnchor.constraint(
            equalToConstant: SpinnerRefreshControl.spinnerHeight
        ).isActive = true
        self.spinnerView = spinnerView
    }
}
