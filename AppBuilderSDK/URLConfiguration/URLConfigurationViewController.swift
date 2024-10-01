import PrimeSDK
import SnapKit
import UIKit

class URLConfigurationViewController: UIViewController {
    enum ConfigurationType {
        case local, remote

        var name: String {
            switch self {
            case .local:
                return "Local"
            case .remote:
                return "Remote"
            }
        }
    }

    typealias Configuration = (type: ConfigurationType, path: String)

    let defaults = UserDefaults.standard

    let localConfigurations = [
        "AppConfiguration",
        "AppConfigurationTechnolab",
        "AppConfigurationArmenia"
    ]

    var configurations = [Configuration]()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(URLConfigurationCell.self, forCellReuseIdentifier: "\(URLConfigurationCell.self)")
        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    override func loadView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(backgroundView.snp.margins)
        }

        self.view = backgroundView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadConfigurations()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setRightBarButton(
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(openAddURL)
            ),
            animated: true
        )
    }

    func reloadConfigurations() {
        let remoteConfigurations = defaults.stringArray(forKey: "remote_urls") ?? []
        configurations =
            localConfigurations.map { Configuration(type: .local, path: $0) } +
            remoteConfigurations.map { Configuration(type: .remote, path: $0) }
        tableView.reloadData()
    }

    func update(configuration: Configuration) {
        var configurationService: ConfigurationLoadingService
        switch configuration.type {
        case .local:
            configurationService = LocalConfigurationLoadingService(fileName: configuration.path)
        case .remote:
            configurationService = RemoteConfigurationLoadingService(
                path: configuration.path,
                headers: [:]
            )
        }
        NotificationCenter.default.post(
            name: .configuartionUpdate,
            object: nil,
            userInfo: ["config": configurationService]
        )
    }

    @objc
    func openAddURL() {
        let viewController = AddURLConfigurationViewController()
        show(viewController, sender: self)
    }
}

extension URLConfigurationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configurations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(URLConfigurationCell.self)"
        ) as? URLConfigurationCell else {
            return UITableViewCell()
        }
        let configuration = configurations[indexPath.row]
        cell.typeLabel.text = configuration.type.name
        cell.pathLabel.text = configuration.path
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        update(configuration: configurations[indexPath.row])
    }
}

extension URLConfigurationViewController: UITableViewDelegate {
}
