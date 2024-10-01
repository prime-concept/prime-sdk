import CoreLocation.CLLocation
import GoogleMaps
import UIKit

class DetailViewController: UIViewController, SFViewControllerPresentable {
    @IBOutlet weak var tableView: DetailTableView! {
        didSet {
            self.setToTrack()
        }
    }
    @IBOutlet weak var closeButton: DetailCloseButton!

    private var headerHeightConstraint: NSLayoutConstraint?
    private var headerTopConstraint: NSLayoutConstraint?

    private var draggingStartOffset: CGFloat = 0
    private var isDragging = false

    var headerView: UIView?
    var currentMapView: EmbeddedMapViewProtocol? {
        didSet {
            currentMapView?.delegate = self
        }
    }

    var bottomButton: BookingButton? {
        return nil
    }

    var bookingURL: URL? {
        didSet {
            bottomButton?.isHidden = bookingURL == nil
        }
    }

    private var shouldUseLightStatusBar: Bool = true

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return shouldUseLightStatusBar ? .lightContent : .default
    }

    var constantHeaderHeight: CGFloat = 250

    var headerHeight: CGFloat {
        if statusBarHeight > 20 {
            // Large status bar (e. g. iPhone X)
            return CGFloat(constantHeaderHeight + statusBarHeight)
        } else {
            return CGFloat(constantHeaderHeight)
        }
    }

    var statusBarHeight: CGFloat {
        if shouldUseZeroStatusBarHeight() {
            return 0
        }
        return min(
            UIApplication.shared.statusBarFrame.height,
            UIApplication.shared.statusBarFrame.width
        )
    }

    var rowViews: [(name: String, view: UIView)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()

        setupTableView()
        setupSubviews()
        setupBottomButton()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async { [weak self] in
            self?.updateTableInset()
        }
    }

    func setToTrack() {
    }

    // swiftlint:disable unavailable_function
    func shouldUseZeroStatusBarHeight() -> Bool {
        fatalError("Implement in subclass")
    }
    // swiftlint:enable unavailable_function

    func updateBookingButton(
        with viewModel: DetailBottomButtonViewModel?,
        sdkManager: PrimeSDKManagerProtocol?,
        id: String
    ) {
        guard let viewModel = viewModel else {
            return
        }

        let updateButton = { [weak self] in
            guard let self = self else {
                return
            }
            self.bookingURL = viewModel.url
            self.bottomButton?.setup(with: viewModel.title)
            let backgroundColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
            self.bottomButton?.backgroundColor = viewModel.background ?? backgroundColor
            self.bottomButton?.setTitleColor(viewModel.text ?? .white, for: .normal)
            var additionalInset: CGFloat = 0
            self.bottomButton?.snp.remakeConstraints { make in
                make.leading.equalTo(self.view.snp.leading).offset(15)
                make.trailing.equalTo(self.view.snp.trailing).offset(-15)
                make.height.equalTo(45)
                if #available(iOS 11.0, *) {
                    if self.view.safeAreaInsets.bottom > 0 {
                        make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-11)
                        additionalInset = self.view.safeAreaInsets.bottom + 11
                    } else {
                        make.bottom.equalTo(self.view.snp.bottom).offset(-15)
                        additionalInset = 15
                    }
                } else {
                    make.bottom.equalTo(self.view.snp.bottom).offset(-15)
                    additionalInset = 15
                }
            }
            self.bottomButton?.isHidden = false
            self.tableView.contentInset.bottom = 45 + additionalInset
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }

        if let bookingDelegate = sdkManager?.bookingDelegate {
            bookingDelegate.canBookClub(clubID: id).done { result in
                if result.isProfileFilled == false {
                    let alert = UIAlertController(
                        title: nil,
                        message: NSLocalizedString("ProfileFullfillmentAlert", bundle: .primeSdk, comment: ""),
                        preferredStyle: .alert
                    )
                    let okAction = UIAlertAction(
                        title: NSLocalizedString("GoToProfile", bundle: .primeSdk, comment: ""),
                        style: .default
                    ) { _ in
                        bookingDelegate.openProfile(from: self)
                    }
                    alert.addAction(okAction)
                    let backToClubs = UIAlertAction(
                        title: NSLocalizedString("BackToClubs", bundle: .primeSdk, comment: ""),
                        style: .cancel
                    ) { _ in
                        self.dismiss()
                    }
                    alert.addAction(backToClubs)
//                    self.present(controller: alert)
                } else if result.canBook {
                    updateButton()
                } else {
                    self.bottomButton?.isHidden = true
                }
            }.catch { _ in
                self.bottomButton?.isHidden = true
            }
        } else {
            updateButton()
        }
    }

    private func updateTableInset(isFirstUpdate: Bool = false) {
        let topInset = headerHeight - statusBarHeight
        // Workaround: bounds don't change after contentInset changed
        let delta = topInset - tableView.contentInset.top

        // After first update insets changed but we shouldn't update offset
        if !isFirstUpdate {
            var offset = tableView.contentOffset
            offset.y -= delta
            tableView.contentOffset = offset
        }
        tableView.contentInset.top = topInset
    }

    func setupHeader(headerView: UIView, height: CGFloat) {
        constantHeaderHeight = height
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(headerView, belowSubview: tableView)
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerHeightConstraint = headerView.heightAnchor.constraint(
            equalToConstant: headerHeight
        )
        headerHeightConstraint?.isActive = true
        headerTopConstraint = headerView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor)
        headerTopConstraint?.isActive = true
        self.headerView = headerView
        self.tableView.headerView = headerView

        updateTableInset(isFirstUpdate: true)
    }

    func updateHeaderIfNeeded(height: CGFloat) {
        if constantHeaderHeight != height {
            constantHeaderHeight = height
        }
        headerHeightConstraint?.constant = headerHeight
        updateTableInset(isFirstUpdate: false)
    }

    private func setupSubviews() {
        closeButton.alpha = 0.0
    }

    private func setupTableView() {
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableView.automaticDimension

        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupBottomButton() {
        guard let bottomButton = self.bottomButton else {
            return
        }

        view.addSubview(bottomButton)
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.isHidden = true

        if #available(iOS 11.0, *) {
            bottomButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -15
            ).isActive = true
        } else {
            bottomButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -15
            ).isActive = true
        }
        bottomButton.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
        bottomButton.heightAnchor.constraint(
            equalToConstant: 44
        ).isActive = true

        let widthConstraint = bottomButton.widthAnchor.constraint(
            equalToConstant: 185
        )
        widthConstraint.priority = .init(rawValue: 999)
        widthConstraint.isActive = true

        bottomButton.addTarget(
            self,
            action: #selector(onBottomButtonClick),
            for: .touchUpInside
        )
    }

    func dismiss() {
        dismiss(animated: true)
    }

    private func setupConstraints() {
        var topAnchor: NSLayoutYAxisAnchor

        if #available(iOS 11, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        } else {
            topAnchor = self.topLayoutGuide.bottomAnchor
        }

        tableView.topAnchor.constraint(
            equalTo: topAnchor,
            constant: 0
        ).isActive = true
        closeButton.topAnchor.constraint(
            equalTo: topAnchor,
            constant: 6
        ).isActive = true
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss()
    }

    @objc
    func onBottomButtonClick(_ sender: Any) {
    }

    func showMap(with coords: CLLocationCoordinate2D) {
        let latitude = coords.latitude
        let longitude = coords.longitude
        let zoom = 18.7
        let urlScheme = URL(string: "comgooglemaps://?q=\(latitude),\(longitude)&zoom=\(zoom)")
        if let url = urlScheme {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
        }
        let baseUrl = "https://www.google.com/maps/"
        let coordsUrl = "?q=@\(latitude),\(longitude)"
        let zoomUrl = "&zoom=\(zoom)"
        let url = URL(string: "\(baseUrl)\(coordsUrl)\(zoomUrl)")
        open(url: url)
    }

    // swiftlint:disable:next unavailable_function
    func onShareButtonClick() {
        fatalError("Method should be overriden in concrete implementation")
    }
    // swiftlint:disable:next unavailable_function
    func onAddToFavoriteButtonClick() {
        fatalError("Method should be overriden in concrete implementation")
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowViews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let view = rowViews[indexPath.row].view
        view.removeFromSuperview()

        view.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(view)
        view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true

        cell.contentView.clipsToBounds = false
        cell.clipsToBounds = false
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        return cell
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let heightOffset = min(statusBarHeight, scrollView.contentOffset.y)

        if heightOffset > statusBarHeight / 2 {
            shouldUseLightStatusBar = false
            self.setNeedsStatusBarAppearanceUpdate()
        } else {
            shouldUseLightStatusBar = true
            self.setNeedsStatusBarAppearanceUpdate()
        }

        let boundaryOffset = headerHeight - statusBarHeight
        let isDraggedDown = heightOffset < -boundaryOffset
        if isDraggedDown {
            headerTopConstraint?.constant = 0
            headerHeightConstraint?.constant = -heightOffset + statusBarHeight
            closeButton.alpha = 0.0
        } else {
            headerTopConstraint?.constant = -(boundaryOffset + heightOffset)
            headerHeightConstraint?.constant = headerHeight

            let closeButtonAlpha = min(1.0, max(0, -heightOffset / statusBarHeight))
            closeButton.alpha = 1.0 - closeButtonAlpha
        }

        let yOffset = scrollView.contentOffset.y
        if isDragging && yOffset + headerHeight < 0 {
            let offsetDiff = abs(draggingStartOffset - yOffset)
            let percent = offsetDiff / view.frame.height
            let dismissThreshold: CGFloat = 0.08
            if percent > dismissThreshold {
                dismiss(animated: true, completion: nil)
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        draggingStartOffset = scrollView.contentOffset.y
        isDragging = true
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        isDragging = false
    }
}

extension DetailViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        showMap(with: coordinate)
    }
}
