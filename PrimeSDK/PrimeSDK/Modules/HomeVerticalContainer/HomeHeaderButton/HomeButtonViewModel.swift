import Foundation

struct HomeButtonViewModel: ViewModelProtocol, Codable {
    var viewName: String = ""

    var attributes: [String: Any] {
        return [:]
    }

    var text: String
    let textColor: UIColor
    let alpha: Float
    let isHidden: Bool
    var url: String
    let radius: Float

    var config: HomeHeaderButtonViewConfig

    init(
        name: String,
        valueForAttributeID: [String: Any],
        defaultAttributes: HomeVerticalContainerConfigView.Attributes
    ) {
        self.viewName = name
        self.text = (valueForAttributeID["text"] as? String) ?? defaultAttributes.text
        self.alpha = (valueForAttributeID["alpha"] as? Float) ?? defaultAttributes.alpha
        self.isHidden = (valueForAttributeID["isHidden"] as? Bool) ?? defaultAttributes.isHidden
        self.radius = (valueForAttributeID["radius"] as? Float) ?? defaultAttributes.radius
        self.url = (valueForAttributeID["url"] as? String) ?? defaultAttributes.url
        self.textColor = (valueForAttributeID["textColor"] as? UIColor) ?? defaultAttributes.textColor

        self.config = HomeHeaderButtonViewConfig(
            isHidden: isHidden,
            title: text,
            textColor: textColor,
            alpha: alpha,
            cornerRadius: CGFloat(radius)
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.viewName = try container.decode(String.self, forKey: .viewName)
        self.text = try container.decode(String.self, forKey: .text)
        self.textColor = UIColor(hex: try container.decode(String.self, forKey: .textColor)) ?? .white
        self.alpha = try container.decode(Float.self, forKey: .alpha)
        self.isHidden = try container.decode(Bool.self, forKey: .isHidden)
        self.url = try container.decode(String.self, forKey: .url)
        self.radius = try container.decode(Float.self, forKey: .radius)

        self.config = HomeHeaderButtonViewConfig(
            isHidden: self.isHidden,
            title: self.text,
            textColor: self.textColor,
            alpha: self.alpha,
            cornerRadius: CGFloat(self.radius)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.viewName, forKey: .viewName)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.textColor.hexString, forKey: .textColor)
        try container.encode(self.alpha, forKey: .alpha)
        try container.encode(self.isHidden, forKey: .isHidden)
        try container.encode(self.url, forKey: .url)
        try container.encode(self.radius, forKey: .radius)
    }

    mutating func update(
        with valueForAttributeID: [String: Any],
        defaultAttributes: HomeVerticalContainerConfigView.Attributes
    ) {
        self.text = (valueForAttributeID["text"] as? String) ?? defaultAttributes.text
        self.url = (valueForAttributeID["url"] as? String) ?? defaultAttributes.url
    }

    enum CodingKeys: String, CodingKey {
        case viewName
        case text
        case textColor
        case alpha
        case isHidden
        case url
        case radius
        case balance
    }
}
