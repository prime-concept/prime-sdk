import Foundation

enum ListViewState: Equatable {
    case normal
    case loading
    case empty
    case error(text: String)
}

protocol ListPresenterProtocol: AnyObject {
    var canViewLoadNewPage: Bool { get }
    var isFavoriteSection: Bool { get }
    var name: String { get }
    var allowsPullToRefresh: Bool { get }
//    var shouldShowTags: Bool { get }
//    var hasHeader: Bool { get }
//    var name: String { get }
//    var manager: PrimeSDKManagerProtocol { get }

    func didAppear()
    func willAppear()
    func refresh()

    func selectItem(at index: Int)

    func loadNextPage()
    func itemSizeType() -> ItemSizeType

    func selectedTag(at index: Int)
    var listDelegate: PrimeSDKListDelegate? { get }

    func getDummyViewModel() -> ListViewModel
}

class AnyListPresenter: ListPresenterProtocol {
    // swiftlint:disable unavailable_function
    var canViewLoadNewPage: Bool {
        fatalError("Implement in subclass")
    }

    var name: String {
        fatalError("Implement in subclass")
    }

    var listDelegate: PrimeSDKListDelegate? {
        fatalError("Implement in subclass")
    }

    var isFavoriteSection: Bool {
        get {
            fatalError("Implement in subclass")
        }
        set {
            fatalError("Implement in subclass")
        }
    }

    var shouldShowTags: Bool {
        get {
            fatalError("Implement in subclass")
        }
        set {
            fatalError("Implement in subclass")
        }
    }

    var hasHeader: Bool {
        fatalError("Implement in subclass")
    }

    var allowsPullToRefresh: Bool {
        fatalError("Implement in subclass")
    }

    var shouldHideScrollIndicator: Bool {
        fatalError("Implement in subclass")
    }

    func didAppear() {
        fatalError("Implement in subclass")
    }

    func willAppear() {
        fatalError("Implement in subclass")
    }

    func refresh() {
        fatalError("Implement in subclass")
    }

    func selectItem(at index: Int) {
        fatalError("Implement in subclass")
    }

    func loadNextPage() {
        fatalError("Implement in subclass")
    }

    func selectedTag(at index: Int) {
        fatalError("Implement in subclass")
    }

    func itemSizeType() -> ItemSizeType {
        fatalError("Implement in subclass")
    }

    var supportAutoItemHeight: Bool {
        fatalError("Implement in subclass")
    }

    func getDummyViewModel() -> ListViewModel {
        fatalError("Implement in subclass")
    }
    // swiftlint:enable unavailable_function
}
