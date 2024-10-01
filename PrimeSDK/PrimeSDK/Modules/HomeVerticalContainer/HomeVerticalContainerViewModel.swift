import UIKit

struct HomeVerticalContainerViewModel: ViewModelProtocol {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    private var subviewsNames: [String] = []
    var subviews: [HomeContainerBlockViewModelProtocol] {
        return subviewsNames.compactMap({ subviewForName[$0] })
    }
    var subviewForName: [String: HomeContainerBlockViewModelProtocol] = [:]

    var header: HomeImageViewModel?
    var headerButton: HomeButtonViewModel?
    var inset: CGFloat

    //swiftlint:disable:next cyclomatic_complexity
    init?(
        name: String,
        valueForAttributeID: [String: Any],
        configView: HomeVerticalContainerConfigView,
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        self.viewName = name
        if
            let cityID = DataStorage.shared.getValue(for: "city-id") as? Int,
            let geoTargetSubviews = configView.geoSubviews.first(where: { $0.cities.contains(cityID) })?.subviews {
            self.subviewsNames = geoTargetSubviews
        } else {
            self.subviewsNames = configView.subviews
        }
        self.inset = CGFloat(configView.attributes.inset)
        self.headerButton = HomeButtonViewModel(
            name: "",
            valueForAttributeID: [:],
            defaultAttributes: configView.attributes
        )
        let otherConfigViews = configuration.views

        if
            let headerViewName = configView.header,
            let headerConfigView = otherConfigViews[headerViewName] as? HomeImageConfigView
        {
            self.header = HomeImageViewModel(
                name: headerConfigView.name,
                valueForAttributeID: valueForAttributeID,
                defaultAttributes: headerConfigView.attributes
            )
        }

        for subviewName in configView.subviews {
            guard let subview = otherConfigViews[subviewName] else {
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
                    let itemConfigView = otherConfigViews[subview.subviews[0]]
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
                    let itemConfigView = otherConfigViews[subview.subviews[0]] as? PopularityChartRowConfigView
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

//    mutating func update(block: HomeContainerBlockViewModelProtocol, name: String) {
//        subviewForName[name] = block
//    }
}
