import UIKit

// swiftlint:disable force_unwrapping
public extension UIImage {
    func tinted(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 3.0)
//        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()

        // flip the image
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.translateBy(x: 0.0, y: -self.size.height)

        // multiply blend mode
        context!.setBlendMode(.multiply)

        let rect = CGRect(origin: .zero, size: self.size)
        context!.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context!.fill(rect)

        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    static func makeImage(of color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)

        UIGraphicsBeginImageContext(rect.size)
        defer {
            UIGraphicsEndImageContext()
        }

        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("Failed to get current context")
        }

        context.setFillColor(color.cgColor)
        context.fill(rect)

        let img = UIGraphicsGetImageFromCurrentImageContext()
        return img!
    }
}
// swiftlint:enable force_unwrapping
