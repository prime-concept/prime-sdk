import Foundation

public class ConfigurationLoadingViewController: UIViewController {
    private let configurationService: ConfigurationLoadingService
    private let apiService: APIService
    private let viewName: String
    private let id: String?
    private let sdkManager: PrimeSDKManagerProtocol

    public init(
        viewName: String,
        id: String? = nil,
        configurationService: ConfigurationLoadingService,
        apiService: APIService,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.viewName = viewName
        self.configurationService = configurationService
        self.apiService = apiService
        self.sdkManager = sdkManager
        self.id = id

        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.white
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        do {
            try load()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func load() throws {
        try configurationService.load().done { [weak self] configuration in
            guard let self = self else {
                return
            }
            if
                let viewConfig = configuration.views[self.viewName],
                let viewType = ViewType(rawValue: viewConfig.type) {
                switch viewType {
                case .list:
                    guard
                        let viewConfiguration = configuration.views[self.viewName] as? ListConfigView
                    else {
                        throw InconsistencyError()
                    }

                    let listAssembly = ListAssembly(
                        name: self.viewName,
                        configuration: configuration,
                        id: nil,
                        viewConfiguration: viewConfiguration,
                        sdkManager: self.sdkManager
                    )

                    self.attach(viewController: listAssembly.make())
                case .detailContainer:
                    guard
//                        let viewConfiguration = configuration.views[self.viewName] as? DetailContainerConfigView,
                        let id = self.id
                    else {
                        throw InconsistencyError()
                    }

                    let detailAssembly = DetailAssembly(
                        name: self.viewName,
                        id: id,
                        configuration: configuration,
                        sdkManager: self.sdkManager
                    )

                    self.attach(viewController: detailAssembly.make())
                case .horizontalListsContainer:
//                    guard
//                        let viewConfiguration = configuration.views[self.viewName] as? HorizontalListsContainerConfigView
//                    else {
//                        throw InconsistencyError()
//                    }

                    let detailAssembly = HorizontalListsContainerAssembly(
                        name: self.viewName,
                        configuration: configuration,
                        sdkManager: self.sdkManager
                    )

                    self.attach(viewController: detailAssembly.make())
                case .navigatorCities:
                    let homeAssembly = NavigatorCitiesAssembly(
                        name: self.viewName,
                        configuration: configuration,
                        sdkManager: self.sdkManager
                    )

                    self.attach(viewController: homeAssembly.make())
                case .homeVerticalContainer:
                    let homeAssembly = HomeVerticalContainerAssembly(
                        name: self.viewName,
                        configuration: configuration,
                        sdkManager: self.sdkManager
                    )

                    self.attach(viewController: homeAssembly.make())

                case .changeCity:
                    let changeCityAssembly = ChangeCityAssembly(
                        name: self.viewName,
                        configuration: configuration,
                        sdkManager: self.sdkManager
                    )

                    self.attach(viewController: changeCityAssembly.make())
                case .kinohodTicketsBooker:
                    let assembly = KinohodTicketsBookerAssembly(
                        name: self.viewName,
                        moduleSource: .movie(id: "24635"),
                        shouldConstrainHeight: false,
                        configuration: configuration,
                        sdkManager: self.sdkManager
                    )
                    self.attach(viewController: assembly.make())
                case .kinohodSearch:
                    let assembly = KinohodSearchAssembly(
                        name: self.viewName,
                        configuration: configuration,
                        sdkManager: self.sdkManager
                    )
                    self.attach(viewController: assembly.make())
                default:
                    fatalError("Unsupported")
                }
            }
        }.catch { error in
            print("configuration error: \(String(describing: error.localizedDescription))")
        }
    }

    private func attach(viewController: UIViewController) {
        self.addChild(viewController)
        self.view.addSubview(viewController.view)

        viewController.view.alignToSuperview()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
    }
}
