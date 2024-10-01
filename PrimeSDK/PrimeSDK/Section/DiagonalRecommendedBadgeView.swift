import UIKit

class DiagonalRecommendedBadgeView: UIView {
    private var imageView: UIImageView?

    override func layoutSubviews() {
        if imageView == nil {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false

//            view.image = #imageLiteral(resourceName: "diagonal-recommended-ru").withRenderingMode(.alwaysTemplate)
            view.tintColor = .white

            self.addSubview(view)

            view.topAnchor.constraint(
                equalTo: self.topAnchor
            ).isActive = true
            view.bottomAnchor.constraint(
                equalTo: self.bottomAnchor
            ).isActive = true
            view.leadingAnchor.constraint(
                equalTo: self.leadingAnchor
            ).isActive = true
            view.trailingAnchor.constraint(
                equalTo: self.trailingAnchor
            ).isActive = true

            self.imageView = view
        }
    }
}
