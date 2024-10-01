import UIKit

final class KeyValueTableViewCell: UITableViewCell {
    var keyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        label.textColor = .black
        return label
    }()

    var valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        label.textColor = .gray
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
        addSubview(keyLabel)
        addSubview(valueLabel)

        keyLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(8)
            make.leading.equalTo(self.snp.leading).offset(16)
            make.height.equalTo(16)
        }

        valueLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom).offset(-8)
            make.leading.equalTo(self.snp.leading).offset(16)
            make.height.equalTo(16)
            make.top.equalTo(keyLabel.snp.bottom).offset(8)
        }
    }
}
