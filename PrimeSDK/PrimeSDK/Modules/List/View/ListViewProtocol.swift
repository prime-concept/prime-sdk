import Foundation
import YandexMobileAds

protocol ListViewProtocol: class,
        CustomErrorShowable {
    func set(imageAd: YMANativeImageAd)

    func set(state: ListViewState)
    func setPagination(state: PaginationState)
    func setScrollIndicatorVisibilty(_ isHide: Bool)

    func update(viewModel: ListViewModel)

    func open(
        model: ViewModelProtocol,
        action: OpenModuleConfigAction,
        config: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    )
    func reloadData()

    var viewController: UIViewController? { get }
}

class AnyListView: CollectionViewController, ListViewProtocol {
// swiftlint:disable unavailable_function
    func set(imageAd: YMANativeImageAd) {
        fatalError("Implement in subclass")
    }

    func set(state: ListViewState) {
        fatalError("Implement in subclass")
    }

    func setPagination(state: PaginationState) {
        fatalError("Implement in subclass")
    }

    func setScrollIndicatorVisibilty(_ isHide: Bool) {
        fatalError("Implement in subclass")
    }

    func update(viewModel: ListViewModel) {
        fatalError("Implement in subclass")
    }
    func updateFavorites(viewModel: ListViewModel, position: Int, toValue: Bool) {
        fatalError("Implement in subclass")
    }

    func open(
        model: ViewModelProtocol,
        action: OpenModuleConfigAction,
        config: Configuration,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        fatalError("Implement in subclass")
    }

    func reloadData() {
        fatalError("Implement in subclass")
    }

    var viewController: UIViewController? {
        fatalError("Implement in subclass")
    }

// swiftlint:enable unavailable_function
}
