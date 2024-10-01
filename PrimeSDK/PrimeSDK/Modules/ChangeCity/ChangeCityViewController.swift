import UIKit

protocol ChangeCityViewProtocol: class {
    func update(viewModel: ChangeCityListViewModel)
    func close()
}

class ChangeCityViewController: UIViewController, ChangeCityViewProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleLabel: UILabel!

    var presenter: ChangeCityPresenterProtocol?

    var viewModel = ChangeCityListViewModel(cities: [])

    private lazy var buttonView: AdvancedFilterButtonSectionView = {
        let view = AdvancedFilterButtonSectionView()
        view.onApplyTap = { [weak self] in
            self?.presenter?.apply()
        }
//        view.onClearTap = { [weak self] in
//            self?.presenter?.clear()
//        }
        return view
    }()

    convenience init() {
        self.init(nibName: "ChangeCityViewController", bundle: .primeSdk)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(ChangeCityCityTableViewCell.self, forCellReuseIdentifier: "\(ChangeCityCityTableViewCell.self)")
        tableView.register(ChangeCityTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "\(ChangeCityTableHeaderView.self)")

        tableView.delegate = self
        tableView.dataSource = self

        searchBar.delegate = self

        self.titleLabel.font = UIFont.font(of: 20, weight: .bold)

        tableView.separatorColor = UIColor.clear
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 85, right: 0)

        addButtons()

        presenter?.didLoad()
        presenter?.refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter?.willDisappear()
    }

    private func addButtons() {
        view.addSubview(buttonView)
        buttonView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }

    func update(viewModel: ChangeCityListViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.title
        tableView.reloadData()
    }

    func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension ChangeCityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelect(section: indexPath.section, item: indexPath.row)
    }
}

extension ChangeCityViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(ChangeCityCityTableViewCell.self)",
            for: indexPath
        ) as? ChangeCityCityTableViewCell else {
            return UITableViewCell()
        }

        cell.setup(viewModel: viewModel.sections[indexPath.section].cities[indexPath.row])

        //It doesn't work if I don't do it here, dont know why
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: ChangeCityTableHeaderView = .fromNib()
        headerView.setup(with: viewModel.sections[section].title)
        return headerView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 43
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 43
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if #available(iOS 11, *) {
            return CGFloat.leastNormalMagnitude
        }
        return 1.1
    }
}

extension ChangeCityViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            presenter?.changeQuery(toQuery: nil)
        } else {
            presenter?.changeQuery(toQuery: searchText)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        presenter?.changeQuery(toQuery: nil)
    }
}
