import UIKit

public extension UILabel {
    func setText(
        _ text: String?,
        lineSpacing: CGFloat = 1.0,
        lineHeightMultiple: CGFloat = 1.0,
        alignment: NSTextAlignment = .natural
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = alignment
        attributedText = NSAttributedString(
            string: text ?? "",
            attributes: [.paragraphStyle: paragraphStyle]
        )
    }
}
