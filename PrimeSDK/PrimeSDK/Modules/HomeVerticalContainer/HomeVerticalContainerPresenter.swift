import Alamofire
import Foundation

protocol HomeVerticalContainerPresenterProtocol {
    func refresh()
    func viewDidScroll(yOffset: CGFloat)
    func bannerButtonClicked( url: String, text: String, img: String, type: String)
    func bannerButtonShown( url: String, text: String, img: String, type: String)
}

class HomeVerticalContainerPresenter: HomeVerticalContainerPresenterProtocol {
    weak var view: HomeVerticalContainerViewProtocol?
    private var apiService: APIService
    private var viewName: String
    private var configuration: Configuration
    private var sdkManager: PrimeSDKManagerProtocol

    private let reachabilityManager: NetworkReachabilityManager?
    private var isPreviousReachable: Bool = false

    init(
        apiService: APIService,
        view: HomeVerticalContainerViewProtocol,
        viewName: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.apiService = apiService
        self.view = view
        self.viewName = viewName
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.reachabilityManager = NetworkReachabilityManager(host: "www.apple.com")

        self.sdkManager.reloadBlockForListName[viewName] = { [weak self] show in
            self?.refresh()
        }
        setupReachability()
    }

    // swiftlint:disable cyclomatic_complexity
    func refresh() {
        guard let configView = configuration.views[viewName] as? HomeVerticalContainerConfigView,
              let header = configView.header,
              let headerConfigView = configuration.views[header] as? HomeImageConfigView,
              let action = configuration.actions[headerConfigView.actions.load],
              let loadImageAction = action as? LoadConfigAction,
              var viewModel = HomeVerticalContainerViewModel(
                name: configView.name,
                valueForAttributeID: [:],
                configView: configView,
                sdkManager: sdkManager,
                configuration: configuration
              ) else {
            return
        }

        // swiftlint:disable line_length
        if let buttonModel: HomeButtonViewModel = CodablePersistenseService.shared.read(from: "headerButtonModel"), let headerModel: HomeImageViewModel = CodablePersistenseService.shared.read(from: "headerModel") {
            viewModel.header = headerModel
            viewModel.headerButton = buttonModel
        }

        loadImageAction.request.inject(action: loadImageAction.name, viewModel: nil)
        loadImageAction.response.inject(action: loadImageAction.name, viewModel: nil)
        loadImageAction.request.modifyUrl(urlPart: self.targetImplementationUrl())
        let request = apiService.request(
            action: loadImageAction.name,
            configRequest: loadImageAction.request,
            configResponse: loadImageAction.response,
            sdkDelegate: sdkManager.apiDelegate
        )

        request
            .promise
            .done { [weak headerConfigView] response in
                guard let headerConfigView = headerConfigView else {
                    return
                }
                viewModel.header?.update(
                    with: response.valueForAttributeID,
                    defaultAttributes: headerConfigView.attributes
                )
                viewModel.headerButton?.update(
                    with: response.valueForAttributeID,
                    defaultAttributes: configView.attributes
                )
                CodablePersistenseService.shared.write(viewModel.headerButton, fileName: "headerButtonModel")
                CodablePersistenseService.shared.write(viewModel.header, fileName: "headerModel")
            }
            .catch { error in
                print("MAIN BANNER ERROR: \(error.localizedDescription)")
            }
            .finally { [weak self] in
                guard let self = self else {
                    return
                }

                var shouldHideFirstTitledHorizontalList = true

                for subview in viewModel.subviews {
                    if let titledHorizontalList = subview as? TitledHorizontalListViewModel {
                        titledHorizontalList.configuration = self.configuration
                        titledHorizontalList.sdkManager = self.sdkManager
                        titledHorizontalList.shouldHideAll = shouldHideFirstTitledHorizontalList
                        viewModel.subviewForName[titledHorizontalList.viewName] = titledHorizontalList
                        shouldHideFirstTitledHorizontalList = false
                    }

                    if let adBannerView = subview as? AdBannerViewModel {
                        viewModel.subviewForName[adBannerView.viewName] = adBannerView
                        adBannerView.delegate = self
                    }

                    if let filterHorizontalList = subview as? FilterHorizontalListViewModel {
                        filterHorizontalList.configuration = self.configuration
                        filterHorizontalList.sdkManager = self.sdkManager
                        viewModel.subviewForName[filterHorizontalList.viewName] = filterHorizontalList
                    }

                    if let moviesPopularityChart = subview as? MoviesPopularityChartViewModel {
                        moviesPopularityChart.configuration = self.configuration
                        moviesPopularityChart.sdkManager = self.sdkManager
                        viewModel.subviewForName[moviesPopularityChart.viewName] = moviesPopularityChart
                    }
                }

                self.sdkManager.homeVerticalContainerDelegate?.updateHeaderImage(
                    isPresent: viewModel.header != nil,
                    viewName: self.viewName
                )

                if
                    viewModel.header == nil,
                    let defaultInset = self.sdkManager.homeVerticalContainerDelegate?.getDefaultTopInset()
                {
                    //If there is no header image, we use add default bar inset
                    self.view?.setDefaultTopInset(inset: defaultInset)
                }
                self.view?.update(viewModel: viewModel)
            }
    }

    func viewDidScroll(yOffset: CGFloat) {
        sdkManager.scrollDelegate?.viewDidScroll(yOffset: yOffset, for: viewName)
    }

	func bannerButtonClicked( url: String, text: String, img: String, type: String) {
        self.sdkManager.analyticsDelegate?.mainBannerButtonClicked(url: url, img: img, text: text, type: type)
    }

    func bannerButtonShown( url: String, text: String, img: String, type: String) {
        self.sdkManager.analyticsDelegate?.mainBannerButtonShown(url: url, img: img, text: text, type: type)
    }

    private func targetImplementationUrl() -> String {
        var target = ""
        if Bundle.main.executableURL?.lastPathComponent == "illuzion" {
            target = "illuzion_ios"
        } else if Bundle.main.executableURL?.lastPathComponent == "cinemastar" {
            target = "cinema_star_ios"
        } else if Bundle.main.executableURL?.lastPathComponent == "moricinema" {
            target = "mori_ios"
        } else {
            target = "kinohod_ios"
        }
        return "?filter[application]=" + target
    }

    private func setupReachability() {
        isPreviousReachable = reachabilityManager?.isReachable ?? false
        reachabilityManager?.listener = { [weak self] status in
            switch status {
            case .notReachable, .unknown:
                self?.view?.updateInternetStatus(isReachable: false)
                self?.sdkManager.listDelegate?.changeHeaderBackground(isReachable: false)
            case .reachable:
                if !(self?.isPreviousReachable ?? true) {
                    self?.view?.updateInternetStatus(isReachable: true)
                    self?.sdkManager.listDelegate?.changeHeaderBackground(isReachable: true)
                    self?.refresh()
                }
            }

            self?.isPreviousReachable = self?.reachabilityManager?.isReachable ?? false
        }

        reachabilityManager?.startListening()
    }
}

extension HomeVerticalContainerPresenter: AdBannerDelegate {
    func heightShouldChange() {
        //TODO: Refresh view height if needed
    }
}

protocol AdBannerDelegate: AnyObject {
    func heightShouldChange()
}
