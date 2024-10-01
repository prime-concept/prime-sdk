import PrimeSDK
import SnapKit
import UIKit

class AddURLConfigurationViewController: UIViewController {
    let defaults = UserDefaults.standard

    lazy var urlTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "URL"
        textField.returnKeyType = .go
        textField.textContentType = .URL
        textField.delegate = self

        return textField
    }()

    override func loadView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.addSubview(urlTextField)

        urlTextField.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.snp.topMargin).offset(20)
            make.leading.equalTo(backgroundView.snp.leading).offset(16)
            make.trailing.equalTo(backgroundView.snp.trailing).offset(16)
            make.height.equalTo(40)
        }

        self.view = backgroundView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextField.becomeFirstResponder()
    }

    @objc
    func close() {
        navigationController?.popViewController(animated: true)
    }

    func addURL() {
        guard let path = urlTextField.text else {
            return
        }
        let configurationsKey = "remote_urls"
        let paths = (defaults.stringArray(forKey: configurationsKey) ?? []) + [path]
        defaults.set(paths, forKey: configurationsKey)
        close()
    }
}

extension AddURLConfigurationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addURL()

        return true
    }
}
