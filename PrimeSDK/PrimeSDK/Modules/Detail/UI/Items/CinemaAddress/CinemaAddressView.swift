import Foundation
import UIKit

class CinemaAddressView: UIView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mallLabel: UILabel!
    @IBOutlet weak var subwayLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var subwayColorView: UIView!

    @IBOutlet weak var mallSubwayDistance: NSLayoutConstraint!
    @IBOutlet weak var addressDistanceDistance: NSLayoutConstraint!

    private var skeletonView: CinemaAddressSkeletonView = .fromNib()
    private var themeProvider: ThemeProvider?

    var isSkeletonShown: Bool = false {
        didSet {
            isSkeletonShown
                ? self.skeletonView.showAnimatedGradientSkeleton()
                : self.skeletonView.hideSkeleton()
            setElements(hidden: isSkeletonShown)
            self.skeletonView.isHidden = !isSkeletonShown
            skeletonView.isUserInteractionEnabled = false
        }
    }

    var shouldShowInAppButton: Bool = true

    private func setElements(hidden: Bool) {
        mallLabel.isHidden = hidden
        subwayLabel.isHidden = hidden
        addressLabel.isHidden = hidden
        distanceLabel.isHidden = hidden
        subwayColorView.isHidden = hidden
    }

    private func setup() {
        self.mallLabel.font = UIFont.font(of: 12, weight: .medium)
        self.subwayLabel.font = UIFont.font(of: 12, weight: .medium)
        self.addressLabel.font = UIFont.font(of: 14, weight: .medium)
        self.distanceLabel.font = UIFont.font(of: 14, weight: .medium)

        self.themeProvider = ThemeProvider(themeUpdatable: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.addSubview(skeletonView)
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        skeletonView.alignToSuperview()
        isSkeletonShown = false

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupContainer()
    }

    var presentBlock: ((UIAlertController) -> Void)?
    var onOpenInAppMap: (() -> Void)?
    var onSelectMapType: ((String) -> Void)?

    var mall: String? {
        didSet {
            mallLabel.text = mall
            if mall == nil || mall?.isEmpty == true {
                mallSubwayDistance.constant = 0
            } else {
                mallSubwayDistance.constant = 8
            }
        }
    }

    var subway: String? {
        didSet {
            subwayLabel.text = subway
        }
    }

    var address: String? {
        didSet {
            addressLabel.text = address
            if address == nil || address?.isEmpty == true {
                addressDistanceDistance.constant = 0
            } else {
                addressDistanceDistance.constant = 3
            }
        }
    }

    var distance: String? {
        didSet {
            if let distance = distance {
                distanceLabel.isHidden = false
                distanceLabel.text = distance
            } else {
                distanceLabel.isHidden = true
            }
        }
    }

    var subwayColor: UIColor? {
        didSet {
            subwayColorView.backgroundColor = subwayColor ?? UIColor.clear
        }
    }

    var coordinate: GeoCoordinate?
    var title: String?

    func setup(viewModel: CinemaAddressViewModel) {
        subway = viewModel.subway?.name
        subwayColor = viewModel.subway?.color
        mall = viewModel.mall
        distance = viewModel.distanceString
        if distance != nil {
            address = viewModel.address + " ·"
        } else {
            address = viewModel.address
        }
        self.coordinate = viewModel.coordinate
        self.title = viewModel.title
    }

    @IBAction func buttonPresssed(_ sender: Any) {
        openMaps()
    }

    //swiftlint:disable:next cyclomatic_complexity
    func openMaps() {
        struct MapApplication {
            let title: String
            let openClosure: (Double, Double, String) -> Void
            let canOpenClosure: () -> Bool
        }

        guard
            let coordinate = self.coordinate,
            let place = self.title.flatMap(
                {
                    $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                }
            ) else {
                return
            }

        let applications: [MapApplication] = [
            MapApplication(
                title: "Яндекс.Карты",
                openClosure: { latitude, longitude, place in
                    guard let url = URL(
                        string: "yandexmaps://maps.yandex.ru/?ll=\(coordinate.longitude),\(coordinate.latitude)&z=17&text=\(place)"
                    ) else {
                        return
                    }
                    self.onSelectMapType?("yandex")
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                },
                canOpenClosure: {
                    guard let url = URL(string: "yandexmaps://") else {
                        return false
                    }

                    return UIApplication.shared.canOpenURL(url)
                }
            ),
            MapApplication(
                title: "Google Карты",
                openClosure: { latitude, longitude, place in
                    guard let url = URL(
                        string: "comgooglemaps://?center=\(coordinate.latitude),\(coordinate.longitude)&q=\(place)&z=18.7"
                    ) else {
                        return
                    }
                    self.onSelectMapType?("google")
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                },
                canOpenClosure: {
                    guard let url = URL(string: "comgooglemaps://") else {
                        return false
                    }

                    return UIApplication.shared.canOpenURL(url)
                }
            ),
            MapApplication(
                title: "Карты",
                openClosure: { latitude, longitude, place in
                    guard let url = URL(
                        string: "http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)&q=\(place)&z=21"
                    ) else {
                        return
                    }
                    self.onSelectMapType?("apple")
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                },
                canOpenClosure: {
                    guard let url = URL(string: "http://maps.apple.com") else {
                        return false
                    }

                    return UIApplication.shared.canOpenURL(url)
                }
            )
        ]

        let availableApplications = applications
            .filter { $0.canOpenClosure() }

        if availableApplications.isEmpty {
            let fallbackPath = "https://www.google.com/maps/?q=@\(coordinate.latitude),\(coordinate.longitude)&zoom=18.7"
            guard let url = URL(string: fallbackPath) else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let alert = UIAlertController(
                title: shouldShowInAppButton ? "\n\n" : nil,
                message: nil,
                preferredStyle: .actionSheet
            )
            if shouldShowInAppButton {
                let mapView: CinemaShowMapView = .fromNib()
                alert.view.addSubview(mapView)
                mapView.snp.makeConstraints { make in
                    make.leading.top.trailing.equalToSuperview()
                    make.height.equalTo(67)
                }
                mapView.onTap = { [weak self] in
                    alert.dismiss(animated: true) {
                        self?.onOpenInAppMap?()
                    }
                }
            }
            for app in availableApplications {
                let button = UIAlertAction(
                    title: app.title,
                    style: .default,
                    handler: { _ in
                        app.openClosure(coordinate.latitude, coordinate.longitude, place)
                    }
                )
                alert.addAction(button)
            }
            let cancelAction = UIAlertAction(
                title: "Отмена",
                style: .cancel
            )
            alert.addAction(cancelAction)
            presentBlock?(alert)
        }
    }

    private func setupContainer() {
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 5
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        let boundsRect = containerView.bounds
        let width = self.bounds.width - 30
        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(x: boundsRect.minX, y: boundsRect.minY, width: width, height: boundsRect.height),
            cornerRadius: containerView.layer.cornerRadius
        ).cgPath
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowRadius = 4.0
        containerView.backgroundColor = UIColor.white
    }
}

extension CinemaAddressView: ThemeUpdatable {
    func update(with theme: Theme) {
        self.distanceLabel.textColor = theme.palette.secondaryColor
    }
}
