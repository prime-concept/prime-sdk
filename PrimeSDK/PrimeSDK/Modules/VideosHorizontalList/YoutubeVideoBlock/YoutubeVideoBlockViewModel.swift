import Foundation

class YoutubeVideoBlockViewModel: ViewModelProtocol {
    static var dummyViewModel = YoutubeVideoBlockViewModel(
        title: "Loading"
    )

    var viewName: String

    var sdkManager: PrimeSDKManagerProtocol?
    var configuration: Configuration?

    var title: String?
    var author: String?
    var previewVideoURL: String?
    var previewImageURL: String?
    var status: YoutubeVideoLiveState?
    var id: String
    var shouldShowPlayButton: Bool

    var attributes: [String: Any] {
        return [:]
    }

    var isDummy: Bool {
        return self.title == "Loading"
    }

    init?(
        name: String,
        valueForAttributeID: [String: Any],
        sdkManager: PrimeSDKManagerProtocol,
        configuration: Configuration
    ) {
        guard let configView = configuration.views[name] as? YoutubeVideoBlockConfigView else {
            return nil
        }
        self.viewName = name
        self.sdkManager = sdkManager
        self.configuration = configuration

        self.id = valueForAttributeID["id"] as? String ?? configView.attributes.id
        self.title = valueForAttributeID["title"] as? String ?? configView.attributes.title
        self.author = valueForAttributeID["author"] as? String ?? configView.attributes.author
        self.previewVideoURL = valueForAttributeID["preview_video"] as? String ?? configView.attributes.previewVideo
        self.previewImageURL = valueForAttributeID["preview_image"] as? String ?? configView.attributes.previewImage
        self.status = YoutubeVideoLiveState(rawValue: valueForAttributeID["status"] as? String ?? "")
        self.shouldShowPlayButton = configView.attributes.shouldShowPlayButton
    }

    init(
        title: String
    ) {
        self.sdkManager = nil
        self.configuration = nil

        self.viewName = ""
        self.title = title
        self.author = nil
        self.previewVideoURL = nil
        self.previewImageURL = nil
        self.status = nil
        self.id = ""
        self.shouldShowPlayButton = false
    }

    func update(snippet: YoutubeVideoSnippet) {
        self.status = snippet.status
        if self.previewImageURL == nil {
            self.previewImageURL = snippet.thumbnailImage
        }
        if self.title == nil {
            self.title = snippet.title
        }
        if self.author == nil {
            self.author = snippet.author
        }
    }
}

extension YoutubeVideoBlockViewModel: VideosHorizontalBlockViewModelProtocol {
    func makeModule() -> VideosHorizontalBlockModule? {
        let viewController = YoutubeVideoBlockViewController()
        viewController.viewModel = self
        return VideosHorizontalBlockModule.viewController(viewController)
    }
}
