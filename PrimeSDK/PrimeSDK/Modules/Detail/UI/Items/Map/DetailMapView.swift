import GoogleMaps
import UIKit

final class DetailMapView: UIView {
    private static let tileCornerRadius: CGFloat = 15
    private static let roundedMarkerCornerRadius: CGFloat = 4

    @IBOutlet private weak var mainLabel: UILabel!
    @IBOutlet private weak var secondaryLabel: UILabel!
    @IBOutlet private weak var tileView: BaseTileView!
    @IBOutlet private weak var roundedMarker: UIView!
    private var mapView: GMSMapView?
    private var marker: GMSMarker?

    weak var delegate: GMSMapViewDelegate?

    var position: CLLocationCoordinate2D? {
        didSet {
            guard let position = position else {
                return
            }
            updateCamera(position: position)
            addMarker(with: position)
        }
    }

    var mainText: String? {
        didSet {
            mainLabel.text = mainText ?? ""
        }
    }

    var secondaryText: String? {
        didSet {
            secondaryLabel.text = secondaryText ?? ""
        }
    }

    func setup(viewModel: DetailMapViewModel) {
        position = viewModel.location.location
        mainText = viewModel.address
        secondaryText = viewModel.metro
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        tileView.cornerRadius = DetailMapView.tileCornerRadius
        tileView.color = UIColor.lightGray.withAlphaComponent(0.35)

        //temp value
        roundedMarker.isHidden = true
        roundedMarker.layer.cornerRadius = DetailMapView.roundedMarkerCornerRadius

        self.setupFonts()

        DispatchQueue.main.async { [weak self] in
            self?.setupMapView()
        }
    }

    private func setupFonts() {
        self.mainLabel.font = UIFont.font(of: 12, weight: .semibold)
        self.secondaryLabel.font = UIFont.font(of: 12, weight: .semibold)
    }

    private func setupMapView() {
        let mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = true
        mapView.settings.setAllGesturesEnabled(false)
        mapView.delegate = delegate
        mapView.layer.cornerRadius = DetailMapView.tileCornerRadius
        tileView.addSubview(mapView)

        mapView.topAnchor.constraint(equalTo: tileView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: tileView.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: tileView.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: tileView.trailingAnchor).isActive = true

        self.mapView = mapView

        if let position = self.position {
            updateCamera(position: position)
            addMarker(with: position)
        }
    }

    private func updateCamera(position: CLLocationCoordinate2D) {
        mapView?.camera = GMSCameraPosition.camera(
            withLatitude: position.latitude,
            longitude: position.longitude,
            zoom: 15.0
        )
    }

    private func addMarker(with position: CLLocationCoordinate2D) {
        if marker == nil {
            marker = GMSMarker()
        }
        marker?.position = position
        marker?.map = mapView
    }

    func set(delegate: GMSMapViewDelegate) {
        self.delegate = delegate
    }
}
