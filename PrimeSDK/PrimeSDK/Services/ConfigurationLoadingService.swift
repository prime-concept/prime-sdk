import Foundation
import PromiseKit
import SwiftyJSON

public protocol ConfigurationLoadingService {
    func load() throws -> Promise<Configuration>
}

public final class RemoteConfigurationLoadingService: ConfigurationLoadingService {
    private var api: APIServiceProtocol
    private var headers: [String: String]
    private var path: String

    private var configuration: Configuration?

    private var localPath: String {
        let startIndex = path.index(after: path.lastIndex(of: Character("/")) ?? path.index(before: path.startIndex))
        return String(path.suffix(from: startIndex))
    }

    private var localURL: URL {
        return FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(localPath)
    }

    public var id: String {
        return path
    }

    public init(
        api: APIServiceProtocol,
        path: String = "https://www.technolab.com.ru/files/AppConfiguration.json",
        headers: [String: String]
    ) {
        self.api = api
        self.path = path
        self.headers = headers
    }

    private func loadLocal() throws -> JSON {
        guard let data = FileManager.default.contents(atPath: localURL.path) else {
            throw ConfigurationFileError()
        }
        let json = try JSON(data: data)
        return json
    }

    func save(json: JSON) throws {
        let data = try json.rawData()
        FileManager.default.createFile(atPath: localURL.path, contents: data, attributes: nil)
    }

    public func load() throws -> Promise<Configuration> {
        return Promise { seal in
            if let configuration = self.configuration {
                seal.fulfill(configuration)
                return
            }
            api.fetchJSON(url: path, headers: headers)
                .done { [weak self] json in
                    let configuration = Configuration(json: json)
                    self?.configuration = configuration
                    try self?.save(json: json)
                    seal.fulfill(configuration)
                }
                .catch { error in
                    if let json = try? self.loadLocal() {
                        seal.fulfill(Configuration(json: json))
                    } else {
                        seal.reject(error)
                    }
                }
        }
    }
}

public final class LocalConfigurationLoadingService: ConfigurationLoadingService {
    public var id: String {
        return fileName
    }

    private static let jsonExtension = "json"
    private var fileName: String

    public init(fileName: String) {
        self.fileName = fileName
    }

    public func load() throws -> Promise<Configuration> {
        guard
            let url = Bundle.main.url(
                forResource: fileName,
                withExtension: LocalConfigurationLoadingService.jsonExtension
            ),
            let jsonData = try? Data(contentsOf: url),
            let json = try? JSON(data: jsonData)
        else {
            throw ConfigurationFileError()
        }

        return Promise { seal in
            seal.fulfill(Configuration(json: json))
        }
    }
}
