import Branch
import Foundation

protocol SharingServiceProtocol {
    func share(action: ShareConfigAction, viewModel: ViewModelProtocol, viewController: UIViewController?)
}

class SharingService: SharingServiceProtocol {
    private var parameterParsingService = ParsingService()
    private var sdkManager: PrimeSDKManagerProtocol

    init(sdkManager: PrimeSDKManagerProtocol) {
        self.sdkManager = sdkManager
    }

    func share(action: ShareConfigAction, viewModel: ViewModelProtocol, viewController: UIViewController?) {
        if let branchObjectSharingParameters = action.sharingParameters as? BranchSharingParameters {
            let title = parameterParsingService.process(
                string: branchObjectSharingParameters.attributes.title,
                action: action.name,
                viewModel: viewModel
            )
            let imagePath = parameterParsingService.process(
                string: branchObjectSharingParameters.attributes.imagePath,
                action: action.name,
                viewModel: viewModel
            )

            if let detailModuleParameters = action.moduleParameters as? DetailModuleParameters {
                let id = parameterParsingService.process(
                    string: detailModuleParameters.attributes.id,
                    action: action.name,
                    viewModel: viewModel
                )
                let name = parameterParsingService.process(
                    string: detailModuleParameters.name,
                    action: action.name,
                    viewModel: viewModel
                )

                shareDetailBranchObject(
                    viewName: (name as? String) ?? "",
                    id: (id as? String) ?? "",
                    title: (title as? String) ?? "",
                    imagePath: (imagePath as? String) ?? ""
                )
            }
        }
        if let urlSharingParameters = action.sharingParameters as? UrlSharingParameters {
            if let urlString = parameterParsingService.process(
                string: urlSharingParameters.attributes.url,
                action: action.name,
                viewModel: viewModel
            ) as? String {
                share(url: urlString, from: viewController)
            }
        }
    }

    private func share(url: String, from viewController: UIViewController? = nil) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        viewController?.present(activityViewController, animated: true)
    }

    private func shareDetailBranchObject(
        viewName: String,
        id: String,
        title: String,
        imagePath: String
    ) {
        let object = BranchUniversalObject(canonicalIdentifier: "detail/\(viewName)/\(id)")
        object.title = title
        object.imageUrl = imagePath

        let linkProperties = BranchLinkProperties()
        linkProperties.addControlParam("framework_source", withValue: "prime_sdk")
        linkProperties.addControlParam("view", withValue: viewName)
        linkProperties.addControlParam("id", withValue: id)
        linkProperties.addControlParam("type", withValue: "detail")

        object.showShareSheet(
            with: linkProperties,
            andShareText: "",
            from: nil,
            completion: { _, completed in
                guard completed else {
                    return
                }
                self.sdkManager.analyticsDelegate?.shareSuccess(viewName: viewName, id: id)
            }
        )
    }
}
