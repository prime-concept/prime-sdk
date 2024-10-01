import Foundation

class AdBannerTableViewCell: UITableViewCell, ViewReusable {
    var module: UIViewController?

    func update(withViewModel viewModel: AdBannerViewModel) {
        let module = viewModel.makeViewController()
        update(withModule: module)
    }

    func update(withModule module: UIViewController) {
        module.view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(module.view)
        module.view.topAnchor.constraint(
            equalTo: self.contentView.topAnchor
            ).isActive = true
        module.view.bottomAnchor.constraint(
            equalTo: self.contentView.bottomAnchor
            ).isActive = true
        module.view.leadingAnchor.constraint(
            equalTo: self.contentView.leadingAnchor
            ).isActive = true
        module.view.trailingAnchor.constraint(
            equalTo: self.contentView.trailingAnchor
            ).isActive = true
        self.module = module
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        module?.view.removeFromSuperview()
    }
}
