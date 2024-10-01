import Foundation
import PromiseKit

protocol VideosHorizontalListPresenterProtocol {
    func reload()
    func didTapQuiz(id: String)

    var loadingViewModel: VideosHorizontalListViewModel? { get }
}

extension VideosHorizontalListPresenter {
    enum QuizBannerError: Error {
        case noBanner
    }

    enum CommonError: Error {
        case noSelf, emptyViewModel
    }
}

final class VideosHorizontalListPresenter: VideosHorizontalListPresenterProtocol {
    weak var view: VideosHorizontalListViewProtocol?

    private var youtubeApiService = YoutubeApiService(
        // swiftlint:disable:next force_cast
        apiKey: DataStorage.shared.getValue(for: "youtube-api-key") as! String
    )

    private var viewName: String
    private var configuration: Configuration
    private var apiService: APIServiceProtocol
    private var sdkManager: PrimeSDKManagerProtocol
    private var viewModel: VideosHorizontalListViewModel?

    lazy var loadingViewModel: VideosHorizontalListViewModel? = {
        self.getDummyViewModel()
    }()

    init(
        view: VideosHorizontalListViewProtocol,
        viewName: String,
        configuration: Configuration,
        apiService: APIServiceProtocol,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.view = view
        self.viewName = viewName
        self.configuration = configuration
        self.apiService = apiService
        self.sdkManager = sdkManager
    }

    func reload() {
        guard
            let configView = configuration.views[viewName] as? VideosHorizontalListConfigView,
            let loadAction = configuration.actions[configView.actions.load] as? LoadConfigAction
        else {
            return
        }

        loadAction.request.inject(action: loadAction.name, viewModel: viewModel)
        loadAction.response.inject(action: loadAction.name, viewModel: viewModel)

        self.view?.setLoading(isLoading: true)

        apiService.request(
            action: loadAction.name,
            configRequest: loadAction.request,
            configResponse: loadAction.response,
            sdkDelegate: sdkManager.apiDelegate
        ).promise.then { [weak self] deserializedViewMap -> Promise<[YoutubeVideoSnippet]> in
            guard let self = self else {
                throw CommonError.noSelf
            }

            let videosViewModel = VideosHorizontalListViewModel(
                name: configView.name,
                valueForAttributeID: deserializedViewMap.valueForAttributeID,
                sdkManager: self.sdkManager,
                configuration: self.configuration
            )

            guard let viewModel = videosViewModel else {
                throw CommonError.emptyViewModel
            }

            self.view?.setLoading(isLoading: false)
            self.view?.update(viewModel: viewModel)
            self.viewModel = viewModel

            let youtubeIDs = viewModel.subviews.compactMap {
                ($0 as? YoutubeVideoBlockViewModel)?.id
            }

            if viewModel.shouldShowQuiz {
                self.updateQuizBannerViewModel()
            }

            return self.youtubeApiService.loadVideoSnippets(ids: youtubeIDs)
        }.done { [weak self] snippets in
            guard let self = self else {
                throw CommonError.noSelf
            }
            self.viewModel?.update(videoSnippets: snippets)
            if let viewModel = self.viewModel {
                self.view?.updateVideos(viewModel: viewModel)
            }
        }.catch { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.view?.setLoading(isLoading: false)
            let videosViewModel = VideosHorizontalListViewModel(
                name: configView.name,
                valueForAttributeID: [:],
                sdkManager: strongSelf.sdkManager,
                configuration: strongSelf.configuration
            )

            guard let viewModel = videosViewModel else {
                return
            }
            viewModel.height = 0

            strongSelf.view?.update(viewModel: viewModel)
        }
    }

    func didTapQuiz(id: String) {
        self.sdkManager.quizDelegate?.didTapQuiz(id: id)
    }

    // MARK: - Private

    private func updateQuizBannerViewModel() {
        self.sdkManager.quizDelegate?.listenQuizBannerViewModel() { [weak self] viewModel in
            self?.view?.updateQuizBanner(viewModel: viewModel)
        }
    }

    private func getDummyViewModel() -> VideosHorizontalListViewModel? {
        let viewModel = VideosHorizontalListViewModel(
            name: viewName,
            valueForAttributeID: [:],
            sdkManager: sdkManager,
            configuration: configuration
        )
        viewModel?.subviews = [
            YoutubeVideoBlockViewModel.dummyViewModel,
            YoutubeVideoBlockViewModel.dummyViewModel,
            YoutubeVideoBlockViewModel.dummyViewModel
        ]
        return viewModel
    }
}
