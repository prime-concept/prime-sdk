import Foundation

//TODO: Add cached & session storage
public final class DataStorage {
    public static var shared = DataStorage()

    private let sharedStorageName = "shared"

    public func set(value: Any?, for key: String, in storage: String? = nil) {
        guard let value = value else {
            storageForAction[storage ?? sharedStorageName]?.params[key] = nil
            return
        }
        if storageForAction[storage ?? sharedStorageName] == nil {
            storageForAction[storage ?? sharedStorageName] = ActionStorage()
        }
        storageForAction[storage ?? sharedStorageName]?.params[key] = value
    }

    public func getValue(for key: String, in storage: String? = nil) -> Any? {
        let storage = storageForAction[storage ?? sharedStorageName]
        let params = storage?.params
        let value = params?[key]
        return value
    }

    public func clear() {
        storageForAction.removeAll(keepingCapacity: true)
    }

    public var sharedStorageKeys: [String] {
        return (storageForAction[sharedStorageName]?.params.keys).flatMap(Array.init) ?? []
    }

    private init() {}
    private var storageForAction: [String: ActionStorage] = [:]

    private struct ActionStorage {
        var params: [String: Any] = [:]
    }
}
