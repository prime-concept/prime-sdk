import Foundation

protocol VideosHorizontalBlockViewModelProtocol {
    func makeModule() -> VideosHorizontalBlockModule?
}

class VideosHorizontalListViewModel: DetailBlockViewModel, ViewModelProtocol, ListViewModelProtocol, Equatable {
    let detailRow = DetailRow.youtubeVideo

    typealias ItemType = YoutubeVideoBlockViewModel

    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    var height: Float
    var title: String?
    var topInset: Float?
    var shouldShowQuiz: Bool

    var subviews: [VideosHorizontalBlockViewModelProtocol] = []

    var sdkManager: PrimeSDKManagerProtocol
    var configuration: Configuration

    init?(
        name: String,
        valueForAttributeID: [String: Any],
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        guard let configView = configuration.views[name] as? VideosHorizontalListConfigView else {
            return nil
        }

        self.viewName = name
        self.sdkManager = sdkManager
        self.configuration = configuration

        self.height = valueForAttributeID["height"] as? Float ?? configView.attributes.height
        self.title = valueForAttributeID["title"] as? String ?? configView.attributes.title
        self.topInset = valueForAttributeID["top_inset"] as? Float ?? configView.attributes.topInset
        self.shouldShowQuiz = valueForAttributeID["show_quiz"] as? Bool ?? configView.attributes.showQuiz

        self.subviews = initItems(
            valueForAttributeID: valueForAttributeID,
            listName: "video"
        ) { videoValueForAttributeID, _ in
            YoutubeVideoBlockViewModel(
                name: configView.videoBlock,
                valueForAttributeID: videoValueForAttributeID,
                sdkManager: sdkManager,
                configuration: configuration
            )
        }
    }

    func update(videoSnippets: [YoutubeVideoSnippet]) {
        for subview in subviews {
            if
                let youtubeVideoBlockViewModel = subview as? YoutubeVideoBlockViewModel,
                let snippet = videoSnippets.first(where: { $0.id == youtubeVideoBlockViewModel.id }) {
                youtubeVideoBlockViewModel.update(snippet: snippet)
            }
        }
    }

    static func == (
        lhs: VideosHorizontalListViewModel,
        rhs: VideosHorizontalListViewModel
    ) -> Bool {
        return lhs.subviews.count == rhs.subviews.count
    }
}

extension VideosHorizontalListViewModel: HomeContainerBlockViewModelProtocol {
    //TODO: rewrite protocol
    var width: NavigatorHomeElementWidth {
        return .full
    }

    func makeModule() -> HomeBlockModule? {
        let module = VideosHorizontalListAssembly(
            name: viewName,
            configuration: configuration,
            sdkManager: sdkManager,
            viewModel: self
        ).make()

        return .viewController(module)
    }
}
