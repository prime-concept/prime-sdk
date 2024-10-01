import Foundation

public protocol ThemeUpdatable: AnyObject {
    func update(with theme: Theme)
}

public final class ThemeProvider {
    enum Notification {
        static let didThemeUpdate = Foundation.Notification.Name("SDKDidThemeUpdate")
    }

    private var onThemeUpdate: ((Theme) -> Void)?
    private weak var themeUpdatable: ThemeUpdatable?

    private static var currentScheme: Theme = .default

    public static var current: Theme {
        get {
            return self.currentScheme
        }
        set {
            self.currentScheme = newValue
            NotificationCenter.default.post(name: Notification.didThemeUpdate, object: nil)
        }
    }

    public var current: Theme {
        return Self.current
    }

    public init(onThemeUpdate: @escaping (Theme) -> Void, immediateUpdateAfterInit: Bool = true) {
        self.onThemeUpdate = onThemeUpdate

        if immediateUpdateAfterInit {
            onThemeUpdate(Self.current)
        }

        self.subscribe()
    }

    public init(themeUpdatable: ThemeUpdatable, immediateUpdateAfterInit: Bool = true) {
        self.themeUpdatable = themeUpdatable

        if immediateUpdateAfterInit {
            themeUpdatable.update(with: Self.current)
        }

        self.subscribe()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleThemeUpdate),
            name: Notification.didThemeUpdate,
            object: nil
        )
    }

    @objc
    private func handleThemeUpdate() {
        self.onThemeUpdate?(Self.current)
        self.themeUpdatable?.update(with: Self.current)
    }
}
