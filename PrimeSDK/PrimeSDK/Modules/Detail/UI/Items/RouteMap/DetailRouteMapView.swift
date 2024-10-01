import GoogleMaps
import UIKit

final class DetailRouteMapView: UIView {
    private static var tileCornerRadius: CGFloat = 10

    // swiftlint:disable:next implicitly_unwrapped_optional
    var tileView: BaseTileView! = BaseTileView()
    var mapView: GMSMapView?

    weak var delegate: GMSMapViewDelegate? {
        didSet {
            mapView?.delegate = delegate
        }
    }

    var address: String? {
        return nil
    }

    var position: CLLocationCoordinate2D?
    var locations: [CLLocationCoordinate2D] = []
    var polylineString: String = ""

    convenience init() {
        self.init(frame: .zero)

        heightAnchor.constraint(equalToConstant: 230).isActive = true

        addSubview(tileView)
        tileView.translatesAutoresizingMaskIntoConstraints = false
        tileView.attachEdges(
            to: self,
            top: 10,
            left: 15,
            bottom: -10,
            right: -15
        )
        tileView.cornerRadius = DetailRouteMapView.tileCornerRadius
        tileView.color = UIColor.lightGray.withAlphaComponent(0.35)

        setupMapView()
        additionalMapViewSetup()
        layoutMapElements()
    }

    func setup(viewModel: DetailRouteMapViewModel) {
        locations = viewModel.routeLocations.map { CLLocationCoordinate2D(geoCoordinates: $0) }
        if !viewModel.polyline.isEmpty {
            polylineString = viewModel.polyline
        }
        layoutMapElements()
    }

    private func additionalMapViewSetup() {
        mapView?.settings.zoomGestures = true
    }

    private func setupMapView() {
        let mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = true
        mapView.settings.setAllGesturesEnabled(false)
        mapView.delegate = delegate
        mapView.layer.cornerRadius = DetailRouteMapView.tileCornerRadius
        tileView.addSubview(mapView)

        mapView.attachEdges(to: tileView)

        self.mapView = mapView
    }

    func updateCamera(position: CLLocationCoordinate2D) {
        mapView?.camera = GMSCameraPosition.camera(
            withLatitude: position.latitude,
            longitude: position.longitude,
            zoom: 16.9
        )
    }

    func layoutMapElements() {
        let bounds = MapHelper.mapBounds(including: locations)

        //locations
        let iconGenerator = ClusterIconGenerator()
        for (i, location) in locations.enumerated() {
            let icon = iconGenerator.icon(forSize: UInt(i + 1))
            let marker = GMSMarker(position: location)
            marker.icon = icon

            marker.map = mapView
        }

        DispatchQueue.main.async { [weak self] in
            self?.mapView?.moveCamera(.fit(bounds))
        }

        guard
            let path = GMSPath(fromEncodedPath: polylineString)
        else {
            return
        }

        //path
        let polyline = GMSPolyline(path: path)
        let spans = GMSStyleSpans(
            path,
            [
                GMSStrokeStyle.solidColor(UIColor(white: 0, alpha: 0.5)),
                GMSStrokeStyle.solidColor(.clear)
            ],
            [20, 6],
            .rhumb
        )
        polyline.spans = spans
        polyline.map = mapView
        polyline.strokeWidth = 2
    }
}
