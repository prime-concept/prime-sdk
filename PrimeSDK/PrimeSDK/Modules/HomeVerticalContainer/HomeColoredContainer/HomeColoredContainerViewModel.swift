import UIKit

struct HomeColoredContainerViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    private var subviewsNames: [String] = []
    var subviews: [HomeContainerBlockViewModelProtocol] {
        return subviewsNames.compactMap({ subviewForName[$0] })
    }
    var subviewForName: [String: HomeContainerBlockViewModelProtocol] = [:]
    let radius: Float
    let title: String
    let titleColor: UIColor
    let backgroundColorTop: UIColor
    let backgroundColorBottom: UIColor
    let configuration: Configuration
    let sdkManager: PrimeSDKManagerProtocol

    init?(
        name: String,
        valueForAttributeID: [String: Any],
        configView: HomeColoredContainerConfigView,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.viewName = name
        self.configuration = configuration
        self.sdkManager = sdkManager

        self.radius = configView.attributes.radius
        self.title = configView.attributes.title
        self.titleColor = configView.attributes.titleColor
        self.backgroundColorTop = configView.attributes.backgroundColorTop
        self.backgroundColorBottom = configView.attributes.backgroundColorBottom

        self.subviewsNames = configView.subviews
        let configViews = configuration.views

        for subviewName in configView.subviews {
            guard let subview = configViews[subviewName] else {
                continue
            }

            let subviewValueForAttributeID = HomeVerticalContainerViewModel.getValuesForSubview(
                valueForAttributeID: valueForAttributeID,
                subviewName: subviewName
            )

            //TODO: Can replace it with factory
            guard let type = ViewType(rawValue: subview.type) else {
                continue
            }

            switch type {
            case .titledHorizontalList:
                guard
                    let subview = subview as? TitledHorizontalListConfigView,
                    let itemConfigView = configViews[subview.subviews[0]]
                else {
                    continue
                }

                let viewModel = TitledHorizontalListViewModel(
                    name: subview.name,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: subview.attributes,
                    itemView: itemConfigView,
                    shouldHideAll: false
                )
                subviewForName[subview.name] = viewModel
            case .adBannerView:
                guard let subview = subview as? AdBannerConfigView else {
                    continue
                }

                let viewModel = AdBannerViewModel(
                    name: subview.name,
                    configView: subview,
                    sdkManager: sdkManager,
                    delegate: nil,
                    imageAd: nil
                )
                subviewForName[subview.name] = viewModel
            case .filterHorizontalList:
                guard
                    let subview = subview as? FilterHorizontalListConfigView
                else {
                    continue
                }

                let viewModel = FilterHorizontalListViewModel(
                    name: subview.name,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: subview.attributes,
                    configView: subview,
                    sdkManager: sdkManager,
                    configuration: configuration
                )
                subviewForName[subview.name] = viewModel
            case .moviesPopularityChart:
                guard
                    let subview = subview as? MoviesPopularityChartConfigView,
                    let itemConfigView = configViews[subview.subviews[0]] as? PopularityChartRowConfigView
                else {
                    continue
                }

                let viewModel = MoviesPopularityChartViewModel(
                    name: subview.name,
                    valueForAttributeID: subviewValueForAttributeID,
                    defaultAttributes: subview.attributes,
                    itemView: itemConfigView
                )
                subviewForName[subview.name] = viewModel
            case .videosHorizontalList:
                guard
                    let subview = subview as? VideosHorizontalListConfigView
                else {
                    continue
                }

                let viewModel = VideosHorizontalListViewModel(
                    name: subview.name,
                    valueForAttributeID: subviewValueForAttributeID,
                    sdkManager: sdkManager,
                    configuration: configuration
                )
                subviewForName[subview.name] = viewModel
            case .cityGuideBanner:
                guard
                    let subview = subview as? CityGuideBannerConfigView
                else {
                    continue
                }

                guard
                    let viewModel = CityGuideBannerViewModel(
                        name: subview.name,
                        defaultAttributes: subview.attributes,
                        sdkManager: sdkManager,
                        configuration: configuration
                    )
                else {
                    continue
                }

                self.subviewForName[subview.name] = viewModel
            case .loyaltyOnboardingBanner:
                guard
                    let subview = subview as? LoyaltyOnboardingBannerConfigView
                else {
                    continue
                }

                guard
                    let viewModel = LoyaltyOnboardingBannerViewModel(
                        name: subview.name,
                        defaultAttributes: subview.attributes,
                        sdkManager: sdkManager,
                        configuration: configuration
                    )
                else {
                    continue
                }

                self.subviewForName[subview.name] = viewModel
            case .homeColoredContainer:
                guard
                    let subview = subview as? HomeColoredContainerConfigView
                else {
                    continue
                }

                guard
                    let viewModel = HomeColoredContainerViewModel(
                        name: subview.name,
                        valueForAttributeID: subviewValueForAttributeID,
                        configView: subview,
                        sdkManager: sdkManager,
                        configuration: configuration
                    )
                else {
                    continue
                }

                self.subviewForName[subview.name] = viewModel

            default:
                continue
            }
        }
    }
}

extension HomeColoredContainerViewModel: HomeContainerBlockViewModelProtocol {
    func makeModule() -> HomeBlockModule? {
        let controller = HomeColoredContainerAssembly(
            name: self.viewName,
            configuration: self.configuration,
            sdkManager: self.sdkManager
        ).make()

        return .viewController(controller)
    }
}
