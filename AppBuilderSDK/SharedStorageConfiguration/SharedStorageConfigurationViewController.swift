import PrimeSDK
import SnapKit
import UIKit

class SharedStorageConfigurationViewController: UIViewController {
    lazy var keyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Key"
        textField.delegate = self
        return textField
    }()

    lazy var valueTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Value"
        textField.delegate = self
        return textField
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(KeyValueTableViewCell.self, forCellReuseIdentifier: "\(KeyValueTableViewCell.self)")
        tableView.delegate = self
        tableView.dataSource = self

        return tableView
    }()

    let storage = DataStorage.shared
    var storedPairs = OrderedDictionary<String, Any>()

    override func loadView() {
        let backgroundView = UIView()
        backgroundView.tintColor = .white

        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray

        backgroundView.addSubview(keyTextField)
        backgroundView.addSubview(valueTextField)
        backgroundView.addSubview(tableView)
        backgroundView.addSubview(separatorView)

        keyTextField.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.snp.topMargin).offset(16)
            make.leading.equalTo(backgroundView.snp.leading).offset(16)
            make.trailing.equalTo(backgroundView.snp.trailing).offset(16)
            make.height.equalTo(36)
        }

        valueTextField.snp.makeConstraints { make in
            make.top.equalTo(keyTextField.snp.bottom).offset(8)
            make.leading.equalTo(backgroundView.snp.leading).offset(16)
            make.trailing.equalTo(backgroundView.snp.trailing).offset(16)
            make.height.equalTo(36)
        }

        separatorView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.equalTo(backgroundView.snp.leading)
            make.trailing.equalTo(backgroundView.snp.trailing)
            make.top.equalTo(valueTextField.snp.bottom).offset(8)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(8)
            make.leading.equalTo(backgroundView.snp.leading)
            make.trailing.equalTo(backgroundView.snp.trailing)
            make.bottom.equalTo(backgroundView.snp.bottomMargin)
        }

        self.view = backgroundView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        storedPairs = storage.sharedStorageKeys.reduce(into: [:]) { $0[$1] = storage.getValue(for: $1) }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setRightBarButton(
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addPair)
            ),
            animated: false
        )
    }

    @objc
    func addPair() {
        guard
            let key = keyTextField.text,
            let value = valueTextField.text
        else {
            return
        }
        storedPairs[key] = value

        save()

        keyTextField.text = ""
        valueTextField.text = ""
        view.endEditing(true)
        tableView.reloadData()
    }

    func save() {
        storage.clear()
        storedPairs.forEach { (key, value) in
            storage.set(value: value, for: key)
        }
    }
}

extension SharedStorageConfigurationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storedPairs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(KeyValueTableViewCell.self)",
            for: indexPath
        ) as? KeyValueTableViewCell,
            let pair = storedPairs.elementAt(indexPath.row)
        else {
            return UITableViewCell()
        }
        cell.keyLabel.text = pair.key
        cell.valueLabel.text = "\(pair.value)"
        return cell
    }
}

extension SharedStorageConfigurationViewController: UITableViewDelegate {
}

extension SharedStorageConfigurationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == keyTextField {
            valueTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }

        return true
    }
}
