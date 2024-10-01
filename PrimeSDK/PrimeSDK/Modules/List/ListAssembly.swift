import UIKit

public class ListAssembly {
    var name: String
    var configuration: Configuration
    var viewConfiguration: ListConfigView
    var sdkManager: PrimeSDKManagerProtocol
    var id: String?

    init(
        name: String,
        configuration: Configuration,
        id: String?,
        viewConfiguration: ListConfigView,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.name = name
        self.configuration = configuration
        self.id = id
        self.viewConfiguration = viewConfiguration
        self.sdkManager = sdkManager
    }

    public func make() -> UIViewController {
        guard let viewConfig = self.configuration.views[self.name] as? ListConfigView else {
            fatalError("View doesn't match the type")
        }

        for supportedCell in viewConfig.subviews {
            if let cellView = self.configuration.views[supportedCell] {
                guard let viewType = ViewType(rawValue: cellView.type) else {
                    fatalError("Bad design")
                }

                switch viewType {
                case .sectionCard:
                    guard let cellView = cellView as? ListItemConfigView else {
                        fatalError("Wrong type")
                    }
                    return makeItems(attributes: [supportedCell: cellView.attributes])
                case .questCard:
                    guard let cellView = cellView as? QuestCardConfigView else {
                        fatalError("Wrong type")
                    }
                    return makeQuests(attributes: [supportedCell: cellView.attributes])
                case .movieNowCard, .eventNowCard:
                    guard let cellView = cellView as? MovieNowConfigView else {
                        fatalError("Wrong type")
                    }
                    return makeMoviesNow(attributes: [supportedCell: cellView.attributes])
                case .cinemaCard:
                    guard let cellView = cellView as? CinemaCardConfigView else {
                        fatalError("Wrong type")
                    }
                    return makeCinemas(attributes: [supportedCell: cellView.attributes])
                default:
                    fatalError("Unsupported")
                }
            } else {
               fatalError("Bad design")
            }
        }
        fatalError("Bad design")
    }

    private func makeItems(
        attributes: [String: Any]
    ) -> ListViewController {
        let view = ListViewController()
        let presenter = ListPresenter(
            view: view,
            listName: name,
            id: id,
            configuration: configuration,
            apiService: APIService(sdkManager: sdkManager),
            locationService: LocationService(),
            sharingService: SharingService(sdkManager: sdkManager),
            attributesForCellName: attributes,
            viewConfiguration: viewConfiguration,
            sdkManager: sdkManager,
            listItemViewModelFactory: ListItemViewModelFactory()
        )
        view.presenter = presenter

        return view
    }

    private func makeQuests(
        attributes: [String: Any]
    ) -> ListViewController {
        let view = ListViewController()
        let presenter = ListPresenter(
            view: view,
            listName: name,
            id: id,
            configuration: configuration,
            apiService: APIService(sdkManager: sdkManager),
            locationService: LocationService(),
            sharingService: SharingService(sdkManager: sdkManager),
            attributesForCellName: attributes,
            viewConfiguration: viewConfiguration,
            sdkManager: sdkManager,
            listItemViewModelFactory: ListItemViewModelFactory()
        )
        view.presenter = presenter

        return view
    }

    private func makeMoviesNow(
        attributes: [String: Any]
    ) -> ListViewController {
        let view = ListViewController()
        let presenter = ListPresenter(
            view: view,
            listName: name,
            id: id,
            configuration: configuration,
            apiService: APIService(sdkManager: sdkManager),
            locationService: LocationService(),
            sharingService: SharingService(sdkManager: sdkManager),
            attributesForCellName: attributes,
            viewConfiguration: viewConfiguration,
            sdkManager: sdkManager,
            listItemViewModelFactory: ListItemViewModelFactory()
        )
        view.presenter = presenter
        return view
    }

    private func makeCinemas(
        attributes: [String: Any]
    ) -> ListViewController {
        let view = ListViewController()
        let presenter = ListPresenter(
            view: view,
            listName: name,
            id: id,
            configuration: configuration,
            apiService: APIService(sdkManager: sdkManager),
            locationService: LocationService(),
            sharingService: SharingService(sdkManager: sdkManager),
            attributesForCellName: attributes,
            viewConfiguration: viewConfiguration,
            sdkManager: sdkManager,
            listItemViewModelFactory: ListItemViewModelFactory()
        )
        view.presenter = presenter
        return view
    }
}
