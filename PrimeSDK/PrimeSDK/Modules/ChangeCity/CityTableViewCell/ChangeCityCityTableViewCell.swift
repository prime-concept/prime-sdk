import UIKit

class ChangeCityCityTableViewCell: UITableViewCell {
    lazy var cityView: ChangeCityCityView = {
        let view: ChangeCityCityView  = .fromNib()
        //TODO: use SnapKit
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: 0
        ).isActive = true
        view.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: 0
        ).isActive = true
        view.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 0
        ).isActive = true
        view.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: 0
        ).isActive = true

        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(viewModel: ChangeCityListViewModel.City) {
        cityView.setup(cityName: viewModel.name, isSelected: viewModel.isSelected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
