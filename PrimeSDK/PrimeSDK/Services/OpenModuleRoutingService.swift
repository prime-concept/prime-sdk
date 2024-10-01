import DeckTransition
import Foundation
import SafariServices
import UIKit

class OpenModuleRoutingService {
    private var moduleFactory = OpenActionModuleFactory()
    private var parsingService = ParsingService()

    func route(
        using viewModel: ViewModelProtocol? = nil,
        openAction: OpenModuleConfigAction,
        from source: UIViewController,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        if let module = moduleFactory.make(
            using: viewModel,
            openAction: openAction,
            configuration: configuration,
            sdkManager: sdkManager
        ) {
            switch openAction.moduleParameters.type {
            case "detail":
                guard let detailModuleParameters = openAction.moduleParameters as? DetailModuleParameters else {
                    break
                }

                guard let idString: String = parsingService.process(
                    string: detailModuleParameters.attributes.id,
                    action: openAction.name,
                    viewModel: viewModel
                ) as? String else {
                    break
                }

                sdkManager.analyticsDelegate?.detailOpened(
                    viewName: openAction.moduleParameters.name,
                    id: idString,
                    source: viewModel?.viewName ?? ""
                )
            case "list":
                sdkManager.analyticsDelegate?.listOpened(
                    viewName: openAction.moduleParameters.name,
                    attributes: viewModel?.attributes ?? [:]
                )
            default:
                break
            }

            transition(to: module, from: source, with: openAction.transitionType)
        }
    }

    private func transition(
        to destination: UIViewController,
        from source: UIViewController,
        with transitionType: OpenModuleConfigAction.TransitionType
    ) {
        switch transitionType {
        case .push:
            source.navigationController?.pushViewController(destination, animated: true)
        case .modal:
            destination.modalPresentationStyle = .fullScreen
            source.present(destination, animated: true, completion: nil)
        case .card:
            let transitionDelegate = DeckTransitioningDelegate()
            if #available(iOS 13.0, *) {
                destination.modalPresentationStyle = .pageSheet
            } else {
                destination.transitioningDelegate = transitionDelegate
                destination.modalPresentationStyle = .custom
            }
            source.present(destination, animated: true, completion: nil)
        }
    }
}

class OpenActionModuleFactory {
    //TODO: Inject this dependency here
    private var parsingService = ParsingService()

    func make(
        using viewModel: ViewModelProtocol? = nil,
        openAction: OpenModuleConfigAction,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) -> UIViewController? {
        if let listModule = makeListModule(
            openAction: openAction,
            viewModel: viewModel,
            configuration: configuration,
            sdkManager: sdkManager
        ) {
            return listModule
        }

        if let viewModel = viewModel,
            let webPageModule = makeWebPageModule(
                openAction: openAction,
                viewModel: viewModel,
                sdkManager: sdkManager
            ) {
            return webPageModule
        }

        if
            let viewModel = viewModel,
            let detailModule = makeDetailModule(
                openAction: openAction,
                viewModel: viewModel,
                configuration: configuration,
                sdkManager: sdkManager
            ) {
            return detailModule
        }

        if
            let viewModel = viewModel,
            let homeModule = makeNavigatorHomeModule(
                openAction: openAction,
                viewModel: viewModel,
                configuration: configuration,
                sdkManager: sdkManager
            ) {
            return homeModule
        }

        return nil
    }

    private func makeListModule(
        openAction: OpenModuleConfigAction,
        viewModel: ViewModelProtocol?,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) -> UIViewController? {
        guard
            let listModuleParameters = openAction.moduleParameters as? ListModuleParameters,
            let viewConfiguration = configuration.views[listModuleParameters.name] as? ListConfigView
        else {
            return nil
        }

        let idString = parsingService.process(
            string: listModuleParameters.attributes.id,
            action: openAction.name,
            viewModel: viewModel
        ) as? String

        let listAssembly = ListAssembly(
            name: listModuleParameters.name,
            configuration: configuration,
            id: idString,
            viewConfiguration: viewConfiguration,
            sdkManager: sdkManager
        )
        return listAssembly.make()
    }

    private func makeDetailModule(
        openAction: OpenModuleConfigAction,
        viewModel: ViewModelProtocol,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) -> UIViewController? {
        guard let detailModuleParameters = openAction.moduleParameters as? DetailModuleParameters else {
            return nil
        }

        guard let idString: String = parsingService.process(
            string: detailModuleParameters.attributes.id,
            action: openAction.name,
            viewModel: viewModel
        ) as? String else {
            return nil
        }

        let detailAssembly = DetailAssembly(
            name: detailModuleParameters.name,
            id: idString,
            configuration: configuration,
            sdkManager: sdkManager
        )
        return detailAssembly.make()
    }

    private func makeWebPageModule(
        openAction: OpenModuleConfigAction,
        viewModel: ViewModelProtocol,
        sdkManager: PrimeSDKManagerProtocol
    ) -> UIViewController? {
        guard
            let webPageModuleParameters = openAction.moduleParameters as? WebPageModuleParameters,
            let path: String = parsingService.process(
                string: webPageModuleParameters.attributes.url,
                action: openAction.name,
                viewModel: viewModel
            ) as? String ,
            let url = URL(string: path)
        else {
            return nil
        }

        return SFSafariViewController(url: url)
    }

    private func makeNavigatorHomeModule(
        openAction: OpenModuleConfigAction,
        viewModel: ViewModelProtocol,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) -> UIViewController? {
        guard let homeModuleParameters = openAction.moduleParameters as? HomeModuleParameters else {
            return nil
        }

        guard let titleString: String = parsingService.process(
            string: homeModuleParameters.attributes.title,
            action: openAction.name,
            viewModel: viewModel
        ) as? String else {
            return nil
        }


        let homeAssembly = NavigatorHomeAssembly(
            name: homeModuleParameters.name,
            title: titleString,
            configuration: configuration,
            sdkManager: sdkManager
        )

        return homeAssembly.make()
    }
}
