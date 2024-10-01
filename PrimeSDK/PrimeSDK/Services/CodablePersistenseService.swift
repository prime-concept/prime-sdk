import Foundation

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
// swiftlint:disable line_length
public class CodablePersistenseService {
    public static let shared = CodablePersistenseService()

    private lazy var cacheRootURL = try? FileManager.default.url(
           for: .documentDirectory,
           in: .userDomainMask,
           appropriateFor: nil,
           create: true
    ).appendingPathComponent("codable_cache")

    init() {
    }

    func delete(fileName name: String) {
        let filePath = self.filePath(for: name)

        do {
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }
        } catch {
            print(error)
        }
    }

    func write<T: Codable>(_ codable: T, fileName name: String) {
        let filePath = self.filePath(for: name)
        let fileURL = URL(fileURLWithPath: filePath)
        let string = (try! codable.toJSONString()) as String

        guard let data = string.data(using: .utf8) else {
            return
        }

        do {
            let directoryPath = fileURL.deletingLastPathComponent()
                .absoluteString
                .withSanitizedFileSchema

            if FileManager.default.fileExists(atPath: directoryPath),
               FileManager.default.fileExists(atPath: filePath) {
                try data.write(to: fileURL, options: .atomic)
                return
            }

            try FileManager.default.createDirectory(
                atPath: directoryPath,
                withIntermediateDirectories: true
            )

            FileManager.default.createFile(atPath: filePath, contents: data)
        } catch {
            print(error)
        }
    }

    func read<T: Codable>(from fileName: String) -> T? {
        let path = self.filePath(for: fileName)
        let json = (try? String(contentsOfFile: path)) ?? ""
        guard let instance = try? JSONDecoder().decode(T.self, from: json.data(using: .utf8)!) else {
            return nil
        }

        return instance
    }

    private func filePath(for name: String) -> String {
        var path = self.cacheRootURL?.absoluteString ?? ""

        path.append("/\(name).json")
        path = path.withSanitizedFileSchema

        return path
    }

    public func clearCache() {
        guard let path = self.cacheRootURL?.absoluteString else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: path.withSanitizedFileSchema)
        } catch {
            print(error)
        }
    }
}

private extension String {
    var withSanitizedFileSchema: String {
        self.replacingOccurrences(of: "^file:\\/+", with: "/", options: .regularExpression)
    }
}

extension Encodable {
    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let json = object as? [String: Any] else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
            throw DecodingError.typeMismatch(type(of: object), context)
        }
        return json
    }

    /// Converting object to postable JSON
    func toJSONString(_ encoder: JSONEncoder = JSONEncoder()) throws -> NSString {
        let data = try encoder.encode(self)
        let result = String(decoding: data, as: UTF8.self)
        return NSString(string: result)
    }
}
