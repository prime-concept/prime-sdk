import Foundation

struct HomeImageViewModel: ViewModelProtocol, Codable {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    var imagePath: String?
    let imageHeight: CGFloat
    let gradientHeight: CGFloat

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: HomeImageConfigView.Attributes
    ) {
        self.viewName = name
        self.imagePath = (valueForAttributeID["path"] as? String) ?? defaultAttributes.path
        self.imageHeight = CGFloat(
            (valueForAttributeID["height"] as? Float) ?? defaultAttributes.height
        )
        self.gradientHeight = CGFloat(
            (valueForAttributeID["gradient_height"] as? Float) ?? defaultAttributes.gradientHeight
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.viewName = try container.decode(String.self, forKey: .viewName)
        self.imagePath = try container.decode(String.self, forKey: .imagePath)
        self.imageHeight = try container.decode(CGFloat.self, forKey: .imageHeight)
        self.gradientHeight = try container.decode(CGFloat.self, forKey: .gradientHeight)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.viewName, forKey: .viewName)
        try container.encode(self.imagePath, forKey: .imagePath)
        try container.encode(self.imageHeight, forKey: .imageHeight)
        try container.encode(self.gradientHeight, forKey: .gradientHeight)
    }

    mutating func update(
        with valueForAttributeID: [String: Any],
        defaultAttributes: HomeImageConfigView.Attributes
    ) {
        self.imagePath = (valueForAttributeID["path"] as? String) ?? defaultAttributes.path
    }

    enum CodingKeys: String, CodingKey {
        case viewName
        case imagePath
        case imageHeight
        case gradientHeight
    }
}

extension HomeImageViewModel: HomeContainerBlockViewModelProtocol {
    var width: NavigatorHomeElementWidth {
        return .full
    }

    func makeModule() -> HomeBlockModule? {
        let homeImageBlockView: HomeImageView = .fromNib()
        homeImageBlockView.setup(viewModel: self)
        return .view(homeImageBlockView)
    }
}
