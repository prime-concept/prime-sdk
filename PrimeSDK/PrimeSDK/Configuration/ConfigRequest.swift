import Foundation
import SwiftyJSON

public final class ConfigRequest {
    public enum RequestMethod: String {
        case get
        case delete
        case post
        case put
    }

    public enum ContentType: String {
        case json = "application/json"
        case url = "application/x-www-form-urlencoded"
    }

    public var url: String {
        guard let action = action else {
            fatalError("No action")
        }

        if
            let processed = self.parsingService.process(
                string: self.unprocessedURL,
                action: action ,
                viewModel: viewModel
            ) as? String
        {
            return processed
        } else {
            return unprocessedURL
        }
    }

    public var headers: [String: String] {
        var headers: [String: String] = [:]

        guard let action = action else {
            fatalError("No action")
        }

        for (key, value) in self.unprocessedHeaders {
            let result = parsingService.process(
                string: value,
                action: action,
                viewModel: viewModel
            )
            if result is String {
                headers[key] = result as? String
            } else if case let .some(x) = result {
                headers[key] = String(describing: x)
            }
        }
        return headers
    }

    public var parameters: [String: Any] {
        var result: [String: Any] = [:]

        guard let action = action else {
            fatalError("No action")
        }

        for (key, value) in self.unprocessedParameters {
            if let value = value as? String {
                result[key] = parsingService.process(string: value, action: action, viewModel: viewModel)
            } else if let json = value as? JSON {
                if let value = json.string {
                    result[key] = parsingService.process(string: value, action: action, viewModel: viewModel)
                } else {
                    result[key] = json.object
                }
            } else {
                if result[key] != nil {
                    result[key] = value
                }
            }
        }
        return result
    }

    public var method: RequestMethod? {
        guard
            let action = action
        else {
            return nil
        }

        guard let methodString: String = parsingService.process(
            string: unprocessedMethod,
            action: action,
            viewModel: viewModel
        ) as? String else {
            return nil
        }

        return RequestMethod(rawValue: methodString)
    }

    public var contentType: ContentType? {
        guard let contentTypeString = headers["Content-Type"] else {
            return nil
        }

        return ContentType(rawValue: contentTypeString)
    }

    private var unprocessedURL: String
    private var unprocessedHeaders: [String: String] = [:]
    private var unprocessedParameters: [String: Any] = [:]
    private var unprocessedMethod: String

    private var action: String?
    private var viewModel: ViewModelProtocol?
    private var parsingService: ParsingService

    init(
        json: JSON,
        action: String? = nil,
        viewModel: ViewModelProtocol? = nil,
        parsingService: ParsingService
    ) {
        self.unprocessedURL = json["url"].stringValue
        self.unprocessedMethod = json["type"].stringValue

        for headerJSON in json["headers"].dictionaryValue {
            unprocessedHeaders[headerJSON.key] = headerJSON.value.stringValue
        }

        for parameterJSON in json["parameters"].dictionaryValue {
            unprocessedParameters[parameterJSON.key] = parameterJSON.value
        }

        self.action = action
        self.viewModel = viewModel
        self.parsingService = parsingService
    }

    func inject(action: String?, viewModel: ViewModelProtocol?) {
        self.action = action
        self.viewModel = viewModel
    }

    func modifyUrl(urlPart: String) {
		if self.unprocessedURL.contains(urlPart) {
			return
		}

		self.unprocessedURL += urlPart
    }
}
