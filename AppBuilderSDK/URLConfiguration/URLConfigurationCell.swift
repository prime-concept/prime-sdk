import UIKit

final class URLConfigurationCell: UITableViewCell {
    var typeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        label.textColor = .gray
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 800), for: .horizontal)
        return label
    }()

    var pathLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        setupUI()
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubview(typeLabel)
        addSubview(pathLabel)

        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(16)
            make.leading.equalTo(self.snp.leading).offset(16)
            make.height.equalTo(16)
        }

        pathLabel.snp.makeConstraints { make in
            make.leading.equalTo(typeLabel.snp.trailing).offset(8)
            make.trailing.equalTo(self.snp.trailing).offset(-16)
            make.top.equalTo(self.snp.top).offset(16)
            make.bottom.equalTo(self.snp.bottom).offset(-16)
        }
    }
}
