import Foundation

public class QuizBannerViewModel {
    public var id: String = ""
    public var slogan: String = ""
    public var imagePath: String = ""
    public var subtitle: String = ""
    public var title: String = ""
    public var rating: String?
    public var description: [String] = []
    public var prizeImagePath: String = ""

    public init() {}
}

extension QuizBannerViewModel: VideosHorizontalBlockViewModelProtocol {
    func makeModule() -> VideosHorizontalBlockModule? {
        let view = QuizBannerView()
        view.update(viewModel: self)
        return VideosHorizontalBlockModule.view(view)
    }
}
