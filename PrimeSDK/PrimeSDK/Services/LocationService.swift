import CoreLocation
import Foundation
import MapKit
import PromiseKit

public typealias LocationFetchCompletion = (LocationResult) -> Void
public typealias RegionFetchCompletion = (CLRegion) -> Void

public enum LocationResult {
    case success(CLLocationCoordinate2D)
    case error(LocationError)
}

public enum LocationError: Error {
    case notAllowed
    case restricted
    case systemError(Error)
    case timeout
}

public protocol LocationServiceProtocol {
    /// Last fetched location
    var lastLocation: CLLocation? { get }

    /// Get current location of the device once
    func getLocation(completion: @escaping LocationFetchCompletion)

    /// Get current location with promise
    func getLocation() -> Promise<GeoCoordinate>

    /// Continuously get current location of the device
    func startGettingLocation(completion: @escaping LocationFetchCompletion)

    /// Stop getting location of the device.
    /// Should be used after calling `startGettingLocation(completion:)`
    func stopGettingLocation()

    /// Distance in meters from the last fetched location
    func distance(to coordinate: GeoCoordinate?) -> Double?

    /// Completion handler of region entrance
    var regionFetchCompltion: RegionFetchCompletion? { get set }

    /// Check if geo regions monitoring is available
    var canMonitor: Bool { get }

    /// Start monitoring if user enters the region
    func startMonitoring(for region: CLRegion)

    /// Stop monitoring if user enters the region
    func stopMonitoring(for region: CLRegion)

    // Location settings current status
    func locationServiceEnabled() -> Bool
}

public final class LocationService: CLLocationManager, LocationServiceProtocol {
    private var oneTimeFetchCompletion: LocationFetchCompletion?
    private var continuousFetchCompletion: LocationFetchCompletion?
    public var regionFetchCompltion: RegionFetchCompletion?


    public var lastLocation: CLLocation?

    public var canMonitor: Bool {
        return
            CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) &&
            CLLocationManager.authorizationStatus() == .authorizedAlways
    }

    let locationTimeOutSeconds: Double = 1

    override public init() {
        super.init()

        desiredAccuracy = kCLLocationAccuracyBest
        distanceFilter = 50
        delegate = self
    }

    public func getLocation(completion: @escaping LocationFetchCompletion) {
        if let lastLocation = lastLocation {
            completion(.success(lastLocation.coordinate))
            return
        }

        oneTimeFetchCompletion = completion
        requestWhenInUseAuthorization()
        startUpdatingLocation()
        DispatchQueue.main.asyncAfter(
            deadline: .now() + locationTimeOutSeconds,
            execute: { [weak self] in
                if let lastLocation = self?.lastLocation {
                    completion(.success(lastLocation.coordinate))
                    return
                } else {
                    completion(.error(.timeout))
                }
            }
        )
    }

    public func getLocation() -> Promise<GeoCoordinate> {
        return Promise { seal in
            getLocation(completion: { result in
                switch result {
                case .error(let error):
                    seal.reject(error)
                case .success(let coordinate):
                    seal.fulfill(GeoCoordinate(location: coordinate))
                }
            }
            )
        }
    }

    public func startGettingLocation(completion: @escaping LocationFetchCompletion) {
        continuousFetchCompletion = completion
        requestWhenInUseAuthorization()
        startUpdatingLocation()
    }

    public func stopGettingLocation() {
        stopUpdatingLocation()
        continuousFetchCompletion = nil
    }

    public func distance(to coordinate: GeoCoordinate?) -> Double? {
        let locationA = coordinate.flatMap(CLLocation.init)
        let locationB = lastLocation
        guard
            (coordinate?.latitude ?? 100) < 90 && (coordinate?.latitude ?? 100) > -90 &&
            (coordinate?.longitude ?? 190) < 180 && (coordinate?.longitude ?? 190) > -180
        else {
            return nil
        }
        return locationA.flatMap { locationB?.distance(from: $0) }
    }

    public func locationServiceEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }

    private func update(result: LocationResult) {
        oneTimeFetchCompletion?(result)
        continuousFetchCompletion?(result)
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location: CLLocation = locations.last else {
            return
        }

        lastLocation = location
        update(result: .success(location.coordinate))

        oneTimeFetchCompletion = nil
        if continuousFetchCompletion == nil {
            stopUpdatingLocation()
        }
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        switch status {
        case .restricted:
            update(result: .error(.restricted))
        case .denied:
            update(result: .error(.notAllowed))
        // Debug only cases
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways,
             .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            break
        }
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        stopUpdatingLocation()
        switch error._code {
        case 1:
            update(result: .error(.notAllowed))
        default:
            update(result: .error(.systemError(error)))
        }
    }

    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        requestState(for: region) // Debug
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didDetermineState state: CLRegionState,
        for region: CLRegion
    ) {
        print("State check for registered region (unknown:\(state == .unknown), inside:\(state == .inside))")
    }

    public func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {
        regionFetchCompltion?(region)
    }
}
