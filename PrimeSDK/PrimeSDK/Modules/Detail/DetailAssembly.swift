import UIKit

class DetailAssembly {
    var name: String
    var id: String
    var configuration: Configuration
    var sdkManager: PrimeSDKManagerProtocol

    init(name: String, id: String, configuration: Configuration, sdkManager: PrimeSDKManagerProtocol) {
        self.name = name
        self.id = id
        self.configuration = configuration
        self.sdkManager = sdkManager
    }

    func make() -> UIViewController {
        let controller = DetailModuleViewController()
        let presenter = DetailPresenter(
            view: controller,
            detailName: self.name,
            id: self.id,
            configuration: self.configuration,
            apiService: APIService(sdkManager: sdkManager),
            googleMapsService: GoogleMapsService(),
            locationService: LocationService(),
            openModuleRoutingService: OpenModuleRoutingService(),
            sharingService: SharingService(sdkManager: sdkManager),
            eventsLocalNotificationsService: EventsLocalNotificationsService(),
            sdkManager: sdkManager
        )
        controller.presenter = presenter
        return controller
    }
}
