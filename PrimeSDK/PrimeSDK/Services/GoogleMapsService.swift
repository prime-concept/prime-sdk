import Foundation
import GoogleMaps

fileprivate extension String {
    static let googleApiKey = "AIzaSyBhunxcWhUhymvp1qYzADzFKch0TwANpVM"
}

protocol MapsService {
    func register()
}

final class GoogleMapsService: MapsService {
    func register() {
        GMSServices.provideAPIKey(.googleApiKey)
    }
}

public func registerGoogleMaps(with apiKey: String) {
    GMSServices.provideAPIKey(apiKey)
}
