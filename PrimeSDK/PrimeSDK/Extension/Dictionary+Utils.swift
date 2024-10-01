import Foundation

extension Dictionary where Value == Any {
    func has<T>(_ type: T.Type, for key: Key) -> Bool {
        self[key, type] != nil
    }

    subscript<T>(_ key: Key, _ type: T.Type) -> T? {
        self[key] as? T
    }
}
