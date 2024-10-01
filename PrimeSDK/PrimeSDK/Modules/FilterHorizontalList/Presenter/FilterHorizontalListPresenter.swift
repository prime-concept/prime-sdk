import Foundation

protocol FilterHorizontalListPresenterProtocol: class {
    var view: FilterHorizontalListViewProtocol? { get }
    func refresh()
    func didSelect(item: FilterItemViewModel)
}

class FilterHorizontalListPresenter: FilterHorizontalListPresenterProtocol {
    weak var view: FilterHorizontalListViewProtocol?
    var configuration: Configuration
    var viewName: String
    var sdkManager: PrimeSDKManagerProtocol
    var viewModel: FilterHorizontalListViewModel

    init(
        view: FilterHorizontalListViewProtocol,
        viewName: String,
        configuration: Configuration,
        sdkManager: PrimeSDKManagerProtocol,
        viewModel: FilterHorizontalListViewModel
    ) {
        self.view = view
        self.viewName = viewName
        self.configuration = configuration
        self.sdkManager = sdkManager
        self.viewModel = viewModel
    }

    // MARK: - FilterHorizontalListPresenterProtocol
    func didSelect(item: FilterItemViewModel) {
        guard
            let sectionCellConfigView = configuration.views[item.viewName] as? FilterItemConfigView
        else {
            return
        }

        if
            let openAction = configuration.actions[sectionCellConfigView.actions.tap] as? OpenModuleConfigAction
        {
            view?.open(model: item, action: openAction, config: configuration, sdkManager: sdkManager)
        }

        sdkManager.filterHorizontalListDelegate?.didFilterPressed(with: sectionCellConfigView.name)
    }

    func refresh() {
        view?.update(viewModel: viewModel)
    }
}
