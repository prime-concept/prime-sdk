import UIKit

class PaginationCollectionViewFooterView: UICollectionReusableView, ViewReusable {
    private var activityIndicatorView: SpinnerView?
    private var button: UIButton?

    var loadNextBlock: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    func setUp() {
        if activityIndicatorView == nil {
            setUpIndicator()
        }

        if button == nil {
            setUpButton()
        }
    }

    private func setUpIndicator() {
        let indicator = SpinnerView()
        indicator.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(indicator)

        indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 25).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 25).isActive = true

        self.activityIndicatorView = indicator
    }

    private func setUpButton() {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(refreshPressed), for: .touchUpInside)
//        button.setTitle(LS.localize("More"), for: .normal)
//        button.tintColor = ApplicationConfig.Appearance.firstTintColor
        self.addSubview(button)

        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        self.button = button
    }

    @objc
    func refreshPressed() {
        loadNextBlock?()
    }

    func set(state: PaginationState) {
        switch state {
        case .error:
            button?.isHidden = false
            activityIndicatorView?.isHidden = true
        case .loading:
            button?.isHidden = true
            activityIndicatorView?.isHidden = false
        case .none:
            button?.isHidden = true
            activityIndicatorView?.isHidden = true
        }
    }
}

class PaginationView: UIView, ViewReusable {
    private var activityIndicatorView: SpinnerView?
    private var button: UIButton?

    var loadNextBlock: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    func setUp() {
        if activityIndicatorView == nil {
            setUpIndicator()
        }

        if button == nil {
            setUpButton()
        }
    }

    private func setUpIndicator() {
        let indicator = SpinnerView()
        indicator.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(indicator)

        indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 25).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 25).isActive = true

        self.activityIndicatorView = indicator
    }

    private func setUpButton() {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(refreshPressed), for: .touchUpInside)
//        button.setTitle(LS.localize("More"), for: .normal)
//        button.tintColor = ApplicationConfig.Appearance.firstTintColor
        self.addSubview(button)

        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        self.button = button
    }

    @objc
    func refreshPressed() {
        loadNextBlock?()
    }

    func set(state: PaginationState) {
        switch state {
        case .error:
            button?.isHidden = false
            activityIndicatorView?.isHidden = true
        case .loading:
            button?.isHidden = true
            activityIndicatorView?.isHidden = false
        case .none:
            button?.isHidden = true
            activityIndicatorView?.isHidden = true
        }
    }
}
